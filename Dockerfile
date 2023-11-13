# build stage
FROM node:14-alpine as builder

LABEL MAINTAINER="renhz"

WORKDIR /var/maxwin/node-app-example
COPY . /var/maxwin/node-app-example

RUN apk update
RUN apk add tzdata git openssh \
  && cp /usr/share/zoneinfo/Asia/Taipei /etc/localtime \
  && apk del tzdata

RUN npm install --silent && npm run build
RUN npm prune --production && npm cache clean -f && echo "Build End"

# run stage
FROM node:14-alpine
WORKDIR /var/maxwin/node-app-example
COPY ./package.json ./
COPY ./package-lock.json ./
COPY ./tsconfig.json ./
COPY ./tsconfig-paths-bootstrap.js ./
COPY --from=builder /var/maxwin/node-app-example/node_modules ./node_modules
COPY --from=builder /var/maxwin/node-app-example/dist ./dist

CMD [ "npm", "start"]
