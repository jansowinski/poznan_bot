FROM ruby:latest

COPY . /bot
WORKDIR /bot

RUN apt-get update && \
    apt-get install -y && \
    bundle install
