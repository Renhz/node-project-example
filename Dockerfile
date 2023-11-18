# build stage
FROM node:18-alpine as builder

LABEL MAINTAINER="renhz"

WORKDIR /var/maxwin/node-app-yarn3-example
COPY . /var/maxwin/node-app-yarn3-example

RUN apk update
RUN apk add tzdata git openssh \
  && cp /usr/share/zoneinfo/Asia/Taipei /etc/localtime \
  && apk del tzdata

RUN corepack enable
RUN yarn install --immutable
RUN yarn build && echo "Build End"
RUN yarn prod-install ./build
RUN cp -r dist ./build

# run stage
FROM node:18-alpine
WORKDIR /var/maxwin/node-app-yarn3-example
COPY ./tsconfig.json ./
COPY ./tsconfig-paths-bootstrap.js ./
COPY --from=builder /var/maxwin/node-app-yarn3-example/build .

CMD [ "yarn", "start"]
