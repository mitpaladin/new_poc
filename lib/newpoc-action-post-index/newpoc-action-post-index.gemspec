# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'newpoc/action/post/index/version'

Gem::Specification.new do |spec|
  spec.name          = "newpoc-action-post-index"
  spec.version       = Newpoc::Action::Post::Index::VERSION
  spec.authors       = ["Jeff Dickey"]
  spec.email         = ["jdickey@seven-sigma.com"]
  spec.summary       = %q{Index-posts Action for `newpoc`.}
  spec.homepage      = "http://github.com/jdickey/new_poc"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'wisper', '~> 1.6'

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rubocop", ">= 0.28.0"
  spec.add_development_dependency "simplecov", ">= 0.9.1"
  spec.add_development_dependency 'wisper_subscription', '~> 0.2'
  spec.add_development_dependency 'fancy-open-struct'
  spec.add_development_dependency 'awesome_print'

  spec.description   = <<-eos
                         Lists posts available to the current user. Published
                         posts will always be available. Draft posts will only
                         be available if they were authored by the currently
                         logged-in user.
                       eos
  spec.description = spec.description.gsub("\n", ' ').squeeze.strip
end
