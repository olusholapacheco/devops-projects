FROM nginx:alpine

# Create a non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy our HTML file
COPY index.html /usr/share/nginx/html/index.html

# Switch to non-root user
USER appuser

EXPOSE 80
