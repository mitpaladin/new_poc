
# ruby '2.2.2'

source 'https://rails-assets.org' do
  gem 'rails-assets-bootstrap', '~> 3.2.0'
  gem 'rails-assets-bootswatch', '~> 3.2.0'
  gem 'rails-assets-sugar'
  gem 'rails-assets-underscore'
end

source 'https://rubygems.org'

gem 'repository-base', '>= 0.2.0'
gem 'wisper_subscription', '>= 0.2.0'

gem 'active_attr'
gem 'attire'
gem 'bcrypt-ruby'
gem 'coffee-rails'
gem 'contracts'
gem 'fancy-open-struct'
gem 'friendly_id'
gem 'gemoji'
gem 'github-linguist'
gem 'github-markdown'
gem 'htmlentities'
gem 'html-pipeline'
gem 'jquery-rails'
gem 'markdown-toolbar', github: 'fuksito/markdown-toolbar'
gem 'naught', github: 'avdi/naught'
gem 'pg'
gem 'pygments.rb'
gem 'rails', '4.2.1'
gem 'rinku'
gem 'sanitizer'
gem 'sass-rails'
gem 'slim-rails', github: 'slim-template/slim-rails'
gem 'passenger'
gem 'uglifier'
gem 'validates_email_format_of'
gem 'value_object'
gem 'wisper'
gem 'yajl-ruby'

group :doc do
  gem 'sdoc'
end

group :development do
  gem 'rails_best_practices', require: false
  # Code smell detection; arguably better than CodeClimate's.
  gem 'reek', require: false
  # Basic structural-similarity analysis utility
  gem 'flay', require: false
  # One view of "complexity".
  gem 'flog', require: false
  gem 'metric_fu-Saikuro', require: false
  gem 'churn', github: 'danmayer/churn', require: false
  gem 'roodi', require: false
  gem 'rubocop', require: false

  gem 'annotate', github: 'ctran/annotate_models'
  # gem 'better_errors' # replaced by 'web-console'
  gem 'web-console' # replaces 'better_errors'
  # gem 'bullet'
  # 'rking/pry-full' hasn't been maintained since Feb 2013; breaks Ruby 2.1.
  # Its individual *components* are mostly fixed, so...
  # gem 'pry-full'
  gem 'pry'
  gem 'pry-doc'
  gem 'pry-theme'
  # gem 'pry-pretty-numeric'
  # gem 'pry-syntax-hacks'
  gem 'pry-highlight'
  # gem 'pry-editline'
  # gem 'pry-git'
  # gem 'pry-developer_tools'
  gem 'awesome_print'
  # End of 'pry-full' foolishness.
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'pry-rescue'
  gem 'pry-stack_explorer'
  gem 'rails-footnotes'
  gem 'spring'
end

group :development, :test do
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'chronic', github: 'mojombo/chronic'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'quiet_assets'
  gem 'rspec'
  gem 'rspec-collection_matchers'
  gem 'rspec-html-matchers'
  gem 'rspec-http'
  gem 'rspec-rails'
  gem 'ruby-growl'
  gem 'simplecov'
  gem 'tapout'
  gem 'teaspoon', '~> 0.9'
end

group :test do
  gem 'codeclimate-test-reporter', require: nil
end
