FROM ruby:2.7-alpine

LABEL version="0.0.1"
LABEL repository="https://github.com/josephbales/blog-builder-action"
LABEL homepage="https://github.com/josephbales/blog-builder-action"
LABEL maintainer="Joseph Bales <joey@josephbales.com>"

RUN apk add --no-cache git build-base
# Allow for timezone setting in _config.yml
RUN apk add --update tzdata

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]