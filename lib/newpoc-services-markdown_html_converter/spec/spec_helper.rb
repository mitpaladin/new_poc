require 'simplecov'
SimpleCov.start do # 'rails'
  add_filter '/spec/'
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'newpoc/services/markdown_html_converter'
