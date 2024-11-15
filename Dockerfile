FROM ruby:3.2.2-alpine as builder

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs default-mysql-client vim 

RUN gem install bundler
ADD Gemfile Gemfile.lock /articles_app/
ENV RAILS_ENV=production 
RUN RAILS_ENV=${RAILS_ENV} bundle install

FROM ruby:3.2.2-alpine as app

RUN mkdir /articles_app 

WORKDIR /articles_app 

ADD . /articles_app 

RUN mkdir -p tmp/sockets 
RUN mkdir -p tpm/pids

CMD ["sh", "entrypoint.sh"]