FROM node:8.0

RUN apt-get update && \
    apt-get install -y --no-install-recommends mysql-client && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /app

WORKDIR /app

COPY package.json .

RUN yarn install --production

COPY . .

RUN chmod a+x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
