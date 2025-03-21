source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

gem 'active_storage_validations', '0.9.8'
gem 'acts-as-taggable-on'
gem 'bcrypt', '3.1.16'
gem 'bootsnap', '1.16.0', require: false
gem 'bootstrap-sass', '3.4.1'
gem 'bootstrap-will_paginate', '1.0.0'
gem 'devise'
gem 'devise-i18n'
gem 'faker', '2.21.0'
gem 'image_processing', '1.12.2'
gem 'importmap-rails', '1.1.5'
gem 'jbuilder', '2.11.5'
gem 'marked-rails'
gem 'mysql2'
gem 'rack-cors'
gem 'rails', '7.0.4.3'
gem 'rails-i18n'
gem 'ransack'
gem 'redcarpet'
gem 'sassc-rails', '2.1.2'
gem 'stimulus-rails', '1.2.1'
gem 'turbo-rails', '1.4.0'
gem 'will_paginate', '3.3.1'

group :development, :test do
  gem 'debug', '1.7.1', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'show_me_the_cookies'
end

group :development do
  gem 'irb', '1.10.0'
  gem 'puma', '5.6.8'
  gem 'repl_type_completor', '0.1.2'
  gem 'solargraph', '0.50.0'
  gem 'web-console', '4.2.0'
end

group :test do
  gem 'capybara', '3.39.2'
  gem 'guard', '2.18.0'
  gem 'guard-minitest', '2.4.6'
  gem 'minitest', '5.18.0'
  gem 'minitest-reporters', '1.6.0'
  gem 'rails-controller-testing', '1.0.5'
  gem 'selenium-webdriver'
end

group :production do
  gem 'aws-sdk-s3', '1.114.0', require: false
  gem 'unicorn'
end
