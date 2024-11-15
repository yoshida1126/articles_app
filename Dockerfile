FROM ruby:3.2.2 

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs default-mysql-client vim 

ENV RAILS_ENV="production"

RUN mkdir /articles_app 

WORKDIR /articles_app 

ADD Gemfile Gemfile.lock /articles_app/

RUN gem install bundler 
RUN bundle install

ADD . /articles_app 

RUN mkdir -p tmp/sockets 
RUN mkdir -p tpm/pids