# Use nginx as base image
FROM nginx:alpine

# Copy our HTML file into nginx's serving directory
COPY index.html /usr/share/nginx/html/index.html

# Nginx listens on port 80
EXPOSE 80
