# Use Node.js as the base image for building the application
FROM node:20-alpine AS builder

# Set working directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json before installing dependencies
COPY package.json package-lock.json ./

# Install dependencies
RUN npm install --frozen-lockfile

# Copy the entire project and build the app
COPY . .
RUN npm run build

################################################################################
# Stage 2: Create the final image with Nginx
FROM nginx:alpine AS production

# Copy the build output from the builder stage
COPY --from=builder /usr/src/app/build /usr/share/nginx/html

# Expose port 80 (default port for Nginx)
EXPOSE 80

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]
