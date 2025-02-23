FROM swr.cn-southwest-2.myhuaweicloud.com/ks/nginx:latest
EXPOSE 80
COPY ./dist /usr/share/nginx/html
RUN rm /etc/nginx/conf.d/default.conf
COPY ./nginx.conf /etc/nginx/conf.d/
