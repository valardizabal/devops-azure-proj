FROM nginx:alpine

WORKDIR /usr/share/nginx/html

COPY . .   

# Move the config into place
RUN mv nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]