source 'https://rubygems.org'

# Complain if developer not using the common Ruby version
ruby '>= 2.3.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2.10'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Modernizr.js library
gem 'modernizr-rails'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'
gem 'puma'
gem 'nio4r', '2.5.2' # Last version to support ruby 2.3

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# gem 'curation_concerns', git: 'https://github.com/projecthydra-labs/curation_concerns', branch: :member_of_replace
gem 'curation_concerns', git: 'https://github.com/IU-Libraries-Joint-Development/curation_concerns.git', branch: :master
gem 'devise', '>= 4.6.0'
gem 'devise-guests', '~> 0.3'
gem 'hydra-role-management', '~> 0.2.0'
gem 'iiif-presentation', git: 'https://github.com/iiif/osullivan', branch: 'development'
gem 'ldap_groups_lookup', '~> 0.7.0'
gem 'pul_metadata_services', git: 'https://github.com/IU-Libraries-Joint-Development/pul_metadata_services.git', branch: :master
gem 'rsolr', '~> 1.1.0'
gem 'simple_form', '~> 3.2', '< 3.5'

# PDF generation
gem 'prawn'
# gem 'pdf-inspector', '~> 1.2.0', group: [:test]

# Copied from curation_concerns Gemfile.extra
gem 'active-fedora', '11.0.0.rc8', git: 'https://github.com/IU-Libraries-Joint-Development/active_fedora.git', branch: 'v11.0.0.rc8'
gem 'active-triples', '~> 0.10.0'
gem 'active_fedora-noid', '~> 2.0.0'
gem 'hydra-derivatives' # , github: 'projecthydra/hydra-derivatives', branch: 'master'
gem 'hydra-pcdm' # , github: 'projecthydra-labs/hydra-pcdm', branch: 'master'
gem 'hydra-works' # , github: 'projecthydra-labs/hydra-works', branch: 'master'
gem 'net-http-persistent', '~> 2.9.4'
gem 'rake', '~> 12.3.3'

group :development, :test do
  gem 'rubocop', '~> 0.51.0', require: false
  gem 'rubocop-rspec', '~> 1.20.0', require: false
  gem 'simplecov', require: false
  # Call 'byebug' anywhere in the code to stop execution and get a
  # debugger console
  gem "factory_girl_rails"
  gem 'guard-rspec', require: false
  gem 'guard-rubocop', require: false
  gem 'jasmine-jquery-rails'
  gem 'jasmine-rails'
  gem 'pdf-reader', git: 'https://github.com/yob/pdf-reader'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec-rails'
  gem 'rspec_junit_formatter'
  # Use sqlite3 as the database for Active Record
  gem 'sqlite3'
end

gem 'coveralls', require: false
gem 'fcrepo_wrapper', '~> 0.7.0'
gem 'solr_wrapper', '~> 0.19.0'

group :development do
  gem 'capistrano', '3.4.0'
  gem 'capistrano-passenger'
  gem 'capistrano-rails'
  gem 'capistrano-rails-console'
  # Spring speeds up development by keeping your application running
  # in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
end

group :test do
  gem "capybara"
  gem "launchy"
  gem 'rspecproxies'
  gem "vcr", '~> 2.9'
  gem "webmock", '~> 1.0', require: false
end

group :production do
  gem 'dalli'
  gem 'kgio'
  gem 'mysql2'
  #  gem 'pg'
end

gem 'aasm'
gem 'arabic-letter-connector'
gem 'browse-everything', git: 'https://github.com/projecthydra-labs/browse-everything'
gem 'bunny'
gem 'ezid-client'
gem 'iso-639'
gem 'mimemagic', '~> 0.3.7'
# gem 'newrelic_rpm'
gem 'okcomputer'
gem "omniauth-cas"
gem 'openseadragon'
gem 'piwik_analytics', '~> 1.1.0', git: 'https://github.com/IUBLibTech/piwik_analytics'
gem 'posix-spawn'
gem 'redis-namespace'
gem 'rubyzip', '~> 1.3'
gem 'sidekiq'
gem 'sinatra'
gem 'sprockets', '~> 3.7.0'
gem 'sprockets-es6'
gem 'sprockets-rails', '~> 2.3.3'
gem 'string_rtl'

group :staging, :development do
  gem 'ruby-prof'
end

source ENV['CIRCLECI'] == 'true' ? 'http://insecure.rails-assets.org' : 'https://rails-assets.org' do
  gem 'rails-assets-babel-polyfill'
  gem 'rails-assets-bootstrap-select', '1.9.4'
  gem 'rails-assets-jqueryui-timepicker-addon'
end
