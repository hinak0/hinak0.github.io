FROM nginx:alpine

WORKDIR /usr/share/nginx/html

RUN apk add --no-cache curl git

RUN rm -rf ./* && git clone -b gh-pages https://github.com/hinak0/hinak0.github.io.git .

COPY start.sh /start.sh

CMD ["/start.sh"]
