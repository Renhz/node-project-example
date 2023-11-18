# build stage
FROM node:18-alpine as builder

LABEL MAINTAINER="renhz"

WORKDIR /var/maxwin/charger-event-subscriber
COPY . /var/maxwin/charger-event-subscriber

RUN apk update
RUN apk add tzdata git openssh \
  && cp /usr/share/zoneinfo/Asia/Taipei /etc/localtime \
  && apk del tzdata

RUN corepack enable
RUN yarn install --immutable --immutable-cache
RUN yarn build && echo "Build End"
RUN yarn prod-install ./build
RUN cp -r dist ./build

# run stage
FROM node:18-alpine
WORKDIR /var/maxwin/charger-event-subscriber
COPY ./tsconfig.json ./
COPY ./tsconfig-paths-bootstrap.js ./
COPY --from=builder /var/maxwin/charger-event-subscriber/build .

CMD [ "yarn", "start"]
