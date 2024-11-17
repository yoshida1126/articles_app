FROM ruby:3.2.2

ENV DOCKERIZE_VERSION v0.6.1
ENV RAILS_ENV="production"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \ 
    nodejs \
    mariadb-client \
    build-essential \
    wget \
    && wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /articles_app 

COPY Gemfile /articles_app/Gemfile 
COPY Gemfile.lock /articles_app/Gemfile.lock      

RUN gem install bundler
RUN bundle install

RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails db:migrate

COPY . /articles_app
