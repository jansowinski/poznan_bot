FROM golang:1.10.0-alpine3.7 AS build-env

COPY . /go/src/geo
WORKDIR /go/src/geo

RUN apk add --no-cache git && \
    go get ./...  && \
    apk del git && \ 
    go build

FROM alpine
WORKDIR /app
COPY --from=build-env /go/src/geo/ /app/