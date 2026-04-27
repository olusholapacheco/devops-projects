FROM nginx:alpine

# This changes rarely — put first
RUN apk add --no-cache curl

# This changes sometimes
COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80
