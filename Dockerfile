FROM docker.1ms.run/nginx:alpine-perl
EXPOSE 80
COPY ./dist /usr/share/nginx/html
RUN rm /etc/nginx/conf.d/default.conf
COPY ./nginx.conf /etc/nginx/conf.d/
