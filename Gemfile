
# Changing versions? Remember to update ./.ruby-version as well!
ruby '2.1.5'

source 'https://rubygems.org'
source 'https://rails-assets.org'

# *One* problem with "unbuilt Rails dependencies" is that they can't depend on
# *each other*. Hence, including `entity` and `services` "Gems" in main app
# Gemfile even though the main app only uses them in conjunction with (Gemified)
# actions. Hence also massive duplication of simple code *in* action "Gems".
# Why is this? Inter-Gem dependency management is *fxxxing primitive!*
[
  'action-post-edit',
  'action-post-index',
  'action-post-new',
  'action-post-show',
  'action-session-create',
  'action-session-destroy',
  'action-session-new',
  'action-user-edit',
  'action-user-index',
  'action-user-new',
  'action-user-show',
  'entity-post',
  'entity-user',
  'repository-base',
  'services-markdown_html_converter'
].each { |gem_name| gem "newpoc-#{gem_name}", path: "lib/newpoc-#{gem_name}" }

gem 'wisper_subscription', '>= 0.2.0'

gem 'active_attr'
gem 'bcrypt-ruby'
# gem 'bundler-reorganizer'
gem 'coffee-rails'
gem 'fancy-open-struct'
gem 'friendly_id', github: 'petergoldstein/friendly_id', ref: '64a37ddddf'
gem 'htmlentities'
gem 'jbuilder'
gem 'jquery-rails'
gem 'markdown-toolbar', github: 'fuksito/markdown-toolbar'
gem 'naught', github: 'avdi/naught'
gem 'pg'
gem 'rails', '4.2.0'
gem 'rails-assets-bootstrap', '~> 3.2.0'
gem 'rails-assets-bootswatch', '~> 3.2.0'
gem 'rails-assets-sugar'
gem 'rails-assets-underscore'
# gem 'redcarpet'
gem 'sass-rails'
gem 'slim-rails', github: 'slim-template/slim-rails'
gem 'thin'
gem 'uglifier'
gem 'validates_email_format_of'
gem 'wisper'
gem 'yajl-ruby'

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
  gem 'rubocop', require: false
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
  # Original 'c42/rspec-http' WAS abandoned, pre-dating RSpec 2.14(!).
  # NEWS FLASH: 0.11.0 dropped 18 Dec 2014; first new commit in over two years.
  gem 'rspec-http'
  # *Shoddy* release engineering. AIWT, 300+ commits since 3.0.0beta2 on master.
  gem 'rspec-rails' # , github: 'rspec/rspec-rails', branch: '3-1-maintenance'
  gem 'ruby-growl'
  gem 'simplecov'
  gem 'tapout'
  gem 'teaspoon', github: 'modeset/teaspoon'
end
