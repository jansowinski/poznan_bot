FROM ruby:2.5.0-alpine3.7

COPY . /bot
WORKDIR /bot

RUN apk add --update ruby-dev build-base && \
    bundle install && \
    apk del ruby-dev build-base tzdata
ENV TZ=Europe/Warsaw
