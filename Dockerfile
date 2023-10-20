# Use an official Node.js runtime as the base image
FROM node:16

# Set the working directory in the Docker container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json (if available) to the container's working directory
COPY package*.json ./

# Install the application's dependencies inside the Docker container
RUN npm install

# Copy the rest of the application's files (including the resources folder) to the container's working directory
COPY . .

# Specify the command to run when the container starts
CMD [ "npm", "start" ]
