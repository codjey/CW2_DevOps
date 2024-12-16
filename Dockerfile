# Step 1: Use the official Node.js image as the base image
FROM node:14

# Step 2: Set the working directory in the container
WORKDIR /app

# Step 3: Copy the application code into the container
COPY server.js .

# Step 4: Expose the application port (8080)
EXPOSE 8080

# Step 5: Run the Node.js application
CMD ["node", "server.js"]
