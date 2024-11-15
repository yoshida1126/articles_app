FROM ruby:3.2.2

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs default-mysql-client vim

ENV RAILS_ENV=production 

RUN mkdir /articles_app 

WORKDIR /articles_app 

ADD Gemfile Gemfile.lock /articles_app/

ADD . /articles_app 

RUN bundle install
