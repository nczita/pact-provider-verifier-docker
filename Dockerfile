FROM ruby:2-alpine

RUN apk add --no-cache --virtual build-dependencies build-base && \
    gem install bundler --no-document

WORKDIR /app

COPY Gemfile /app/
COPY Gemfile.lock /app/

RUN bundle install && \
    apk del build-dependencies build-base && \
    rm -r ~/.bundle/ /usr/local/bundle/cache

COPY src/ /app/

CMD bundle exec rake verify_pacts
