
ruby '2.1.5'

source 'https://rubygems.org'
source 'https://rails-assets.org'

gem 'active_attr'
gem 'bcrypt-ruby'
# gem 'bundler-reorganizer'
gem 'coffee-rails'
gem 'fancy-open-struct'
gem 'friendly_id', github: 'petergoldstein/friendly_id', ref: '64a37ddddf'
gem 'html-pipeline', github: 'jch/html-pipeline'
# Next few needed for html-pipeline
gem 'gemoji'
gem 'github-linguist'
gem 'github-markdown'
gem 'pygments.rb', github: 'pombredanne/pygments.rb' # '~> 0.6.0'
gem 'rinku'
gem 'sanitize'
# End html-pipeline dependencies
gem 'htmlentities'
gem 'jbuilder'
gem 'jquery-rails'
gem 'markdown-toolbar', github: 'fuksito/markdown-toolbar'
gem 'naught', github: 'avdi/naught'
gem 'pg'
# gem 'rails', '4.1.8'
gem 'rails', '4.2.0'
gem 'rails-assets-bootstrap', '~> 3.2.0'
gem 'rails-assets-bootswatch', '~> 3.2.0'
gem 'rails-assets-sugar'
gem 'rails-assets-underscore'
gem 'redcarpet'
gem 'sass-rails'
gem 'slim-rails', github: 'slim-template/slim-rails'
gem 'thin'
gem 'uglifier'
gem 'validates_email_format_of'
gem 'wisper'
gem 'yajl-ruby', '1.1.0' # for pygments.rb # , github: 'brianmario/yajl-ruby'

group :doc do
  gem 'sdoc'
end

group :development do
  gem 'annotate', github: 'ctran/annotate_models'
  # gem 'better_errors' # replaced by 'web-console'
  gem 'web-console' # replaces 'better_errors'
  gem 'binding_of_caller'
  gem 'bullet'
  gem 'meta_request'
  # metric_fu aggregates flog, flay, metric_fu-Saikuro, churn, reek, roodi,
  # code_statistics, and rails_best_practices; several of which haven't been
  # officially updated in *years*. Perhaps more selective filtering is
  # warranted?
  # gem 'metric_fu', github: 'metricfu/metric_fu'
  gem 'flay'
  gem 'flog'
  gem 'metric_fu-Saikuro'
  gem 'churn', github: 'danmayer/churn'
  gem 'reek'
  gem 'roodi'
  # gem 'code_statistics' # Statistics like it's 2009, apparently
  gem 'rails_best_practices'
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
  gem 'rubocop'
  gem 'spring'
end

group :development, :test do
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'chronic', github: 'mojombo/chronic'
  gem 'database_cleaner', github: 'DatabaseCleaner/database_cleaner'
  gem 'factory_girl_rails'
  gem 'quiet_assets'
  gem 'rspec'
  gem 'rspec-collection_matchers'
  # Fork doesn't have version dependency; *has* RSpec 3 'expect' syntax. Win!
  gem 'rspec-html-matchers' # , github: 'seomoz/rspec-html-matchers'
  # Original 'c42/rspec-http' is abandoned, pre-dates RSpec 2.14(!), now at 3.1.
  # jdickey/rspec-http forked from shishir/rpec-http, which takes us to 2.99.0
  # but needs work for RSpec 3.x.
  gem 'rspec-http', github: 'jdickey/rspec-http', branch: 'rspec-3'
  # *Shoddy* release engineering. AIWT, 300+ commits since 3.0.0beta2 on master.
  gem 'rspec-rails' # , github: 'rspec/rspec-rails', branch: '3-1-maintenance'
  gem 'ruby-growl'
  gem 'simplecov'
  gem 'tapout'
  gem 'teaspoon', github: 'modeset/teaspoon'
end
