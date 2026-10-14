FROM nginx:alpine

RUN rm -rf /usr/share/nginx/html/*
COPY index.html styles.css /usr/share/nginx/html/
EXPOSE 80

