# docker buildx build --platform  linux/amd64,linux/arm64 --tag thornleyk/graviteeioam-service --push .
# https://hub.docker.com/repository/docker/thornleyk/graviteeioam-service

FROM golang:1.20-alpine AS build

RUN apk --no-cache add \
    bash \
    gcc \
    musl-dev \
    openssl
RUN mkdir -p /go/src/github.com/thornleyk/graviteeioam-service
WORKDIR /go/src/github.com/thornleyk/graviteeioam-service
ADD . /go/src/github.com/thornleyk/graviteeioam-service
RUN go build --ldflags '-linkmode external -extldflags "-static"' .

FROM alpine:3.14 AS deploy

WORKDIR /

RUN apk --no-cache add curl
COPY --from=build /go/src/github.com/thornleyk/graviteeioam-service /

HEALTHCHECK --interval=15s --timeout=3s \
  CMD curl -f 127.0.0.1:8080/ || exit 1

ENTRYPOINT ["/graviteeioam-service"]
CMD ["-port", "8080"]
