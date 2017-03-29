FROM node:7.7

RUN apt-get update

RUN apt-get install -y --no-install-recommends mysql-client

RUN mkdir /app

WORKDIR /app

COPY package.json .

RUN npm install --production

COPY . .

RUN chmod a+x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
