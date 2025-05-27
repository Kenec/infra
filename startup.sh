#!/bin/sh

ENVIRONMENT=${ENVIRONMENT:-"Unknown Environment"}  # Set default to "Unknown Environment" if not provided
SECRET_MESSAGE=${SECRET_MESSAGE:-"Unknown Secret"}  # Set default to "Unknown Secret" if not provided


# Replace the placeholders in the HTML with the actual environment and secret values.
sed -i "s/{{ENVIRONMENT}}/${ENVIRONMENT}/g" /usr/share/nginx/html/index.html
sed -i "s/{{SECRET_MESSAGE}}/${SECRET_MESSAGE}/g" /usr/share/nginx/html/index.html

# Start Nginx
nginx -g 'daemon off;'
