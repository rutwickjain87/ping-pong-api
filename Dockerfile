# Use an official Node.js runtime as a parent image
#FROM node:19.8.1 AS build
FROM node:latest AS build

# Install dumb-init
RUN apt update && apt install -y --no-install-recommends dumb-init

# Set the working directory
WORKDIR /usr/src/app

# Copy the package.json and package-lock.json files to the container
COPY package*.json ./

# npm clean install
RUN --mount=type=secret,mode=0644,id=npmrc,target=/usr/src/app/.npmrc npm ci --only=production

# ------ Actual Production Image ------ #

# Use an official slim Node.js images
FROM node:19.8.1-bullseye-slim

# Set environment vars
ENV NODE_ENV production

# Copy dumb-init
COPY --from=build /usr/bin/dumb-init /usr/bin/dumb-init

# Set user to 'node' (non-root user) 
USER node

# Set the working directory
WORKDIR /usr/src/app

# Copy node modules and set appropriate ownership
COPY --chown=node:node --from=build /usr/src/app/node_modules /usr/src/app/node_modules
COPY --chown=node:node . /usr/src/app

# Start nodejs service
CMD ["dumb-init", "node", "server.js"]
