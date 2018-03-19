FROM python:3.6.4-alpine3.7

COPY . /rowery
WORKDIR /rowery

RUN pip install --upgrade pip && pip install -r requirements.txt && apk add --no-cache tzdata
ENV TZ=Europe/Warsaw
