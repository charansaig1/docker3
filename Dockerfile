# syntax=docker/dockerfile:1

# Comments are provided throughout this file to help you get started.
# If you need more help, visit the Dockerfile reference guide at
# https://docs.docker.com/go/dockerfile-reference/

# Want to help us make this template better? Share your feedback here: https://forms.gle/ybq9Krt8jtBL3iCk7

ARG NODE_VERSION=22.13.0

################################################################################
# Use node image for base image for all stages.
FROM node:20-alpine AS builder

# Set working directory for all build stages.
WORKDIR /usr/src/app



# Copy package.json and package-lock.json before installing dependencies
COPY package.json package-lock.json ./

# Install dependencies
RUN npm install --frozen-lockfile

# Copy the entire project and build the app
COPY . .
RUN npm run build

################################################################################
# Stage 2: Build the application
FROM base as build

# Copy the dependencies from the previous stage
COPY --from=dependencies /usr/src/app/node_modules ./node_modules

# Copy the rest of the application code
COPY . .

# Build the application
RUN npm run build

################################################################################
# Stage 3: Create the final image
FROM nginx:alpine as production

# Copy the build output from the previous stage
COPY --from=build /usr/src/app/build /usr/share/nginx/html

# Expose port 3000
EXPOSE 3000

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]
