FROM ruby:2.7-alpine

LABEL version="1.0.1"
LABEL repository="https://github.com/josephbales/blog-builder-action"
LABEL homepage="https://github.com/josephbales/blog-builder-action"
LABEL maintainer="Joseph Bales <joey@josephbales.com>"

RUN apk add --no-cache git build-base

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
RUN ["chmod", "+x", "/entrypoint.sh"]