FROM node:8.0-alpine

RUN apk add --no-cache python mysql-client curl

RUN curl -Ls https://github.com/fgrehm/docker-phantomjs2/releases/download/v2.0.0-20150722/dockerized-phantomjs.tar.gz \
   | tar xz -C /

RUN mkdir /app

WORKDIR /app

COPY package.json .

RUN yarn install --production

COPY . .

RUN chmod a+x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
