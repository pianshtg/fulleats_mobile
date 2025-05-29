# Using official Node.js image as base
FROM node:20.14.0

# Setting the working directory
WORKDIR /usr/src/app

# Copying package.json and install dependencies
COPY package*.json ./
RUN npm install

# Copying all other files into the container
COPY . .

# Running database seeding
RUN npm run seed

# Building the project
RUN npm run build

# Exposing the backend port
EXPOSE 3030

# Starting the backend application
CMD ["npm", "run", "start"]
