FROM golang:1.10.0-alpine3.7

COPY . /go/src/geo
WORKDIR /go/src/geo

RUN apk add --no-cache git && \
    go get ./...  && \
    apk del git