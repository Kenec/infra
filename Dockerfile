FROM nginx:alpine

COPY index.html /usr/share/nginx/html
COPY startup.sh /usr/local/bin/startup.sh

RUN chmod +x /usr/local/bin/startup.sh

ENTRYPOINT ["/usr/local/bin/startup.sh"]

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
