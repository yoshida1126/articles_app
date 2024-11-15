FROM ruby:3.2.2-alpine as builder

RUN apk update && \
  apk add --no-cache \
  build-essential \
  libpq-dev \ 
  nodejs \
  default-mysql-dev \
  vim 

RUN gem install bundler
ADD Gemfile Gemfile.lock /articles_app/
ENV RAILS_ENV=production 
RUN RAILS_ENV=${RAILS_ENV} bundle install

FROM ruby:3.2.2-alpine as app 

RUN apk update && \ 
  apk add --no-cache \
  tzdata \ 
  default-mysql-client

RUN mkdir /articles_app 

WORKDIR /articles_app 

ADD . /articles_app 



CMD ["sh", "entrypoint.sh"]