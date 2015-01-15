# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'newpoc/entity/post/version'

Gem::Specification.new do |spec|
  spec.name          = "newpoc-entity-post"
  spec.version       = Newpoc::Entity::Post::VERSION
  spec.authors       = ["Jeff Dickey"]
  spec.email         = ["jdickey@seven-sigma.com"]
  spec.summary       = %q{Post Entity implementation for `newpoc`.}
  spec.description   = %q{Post Entity implementation for `newpoc`.}
  spec.homepage      = "https://github.com/jdickey/new_poc/"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'active_attr', '>= 0.8.5'
  spec.add_dependency 'html-pipeline', '>= 0.11.0'
  spec.add_dependency 'nokogiri', '>= 1.6.5'
  # Next few needed for html-pipeline
  spec.add_dependency 'gemoji', '>= 2.1.0'
  spec.add_dependency 'github-linguist', '>= 4.2.5'
  spec.add_dependency 'github-markdown', '>= 0.6.0'
  spec.add_dependency 'pygments.rb'
  # gem 'pygments.rb', github: 'lencioni/pygments.rb', branch: 'yajl-update'
  spec.add_dependency 'rinku', '>= 1.7.3'
  spec.add_dependency 'sanitize', '>= 3.1.0'
  # End html-pipeline dependencies

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency 'chronic', '>= 0.10.2'
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.1"
  spec.add_development_dependency "rubocop", ">= 0.28.0"
  spec.add_development_dependency "simplecov", ">= 0.9.1"
  spec.add_development_dependency 'fancy-open-struct', '>= 0.4.0'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'pry-doc'
end
