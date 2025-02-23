FROM harbor.nick-h.cn/qq742037091/nginx:latest
EXPOSE 80
COPY ./dist /usr/share/nginx/html
RUN rm /etc/nginx/conf.d/default.conf
COPY ./nginx.conf /etc/nginx/conf.d/
