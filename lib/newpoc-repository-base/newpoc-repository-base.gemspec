
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'newpoc/repository/base/version'

Gem::Specification.new do |spec|
  spec.name          = "newpoc-repository-base"
  spec.version       = Newpoc::Repository::Base::VERSION
  spec.authors       = ["Jeff Dickey"]
  spec.email         = ["jdickey@seven-sigma.com"]
  spec.summary       = %q{Basic Repository pattern implementation for `new_poc`.}
  spec.description   = %q{Basic Repository pattern implementation for `new_poc`.}
  spec.homepage      = "https://github.com/jdickey/new_poc/"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  # FIXME: Required for ActiveModel::Errors. Need a more lightweight alternate.
  spec.add_dependency 'activemodel', '> 3.2'
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency 'rspec', '~> 3.1'
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'rubocop', '>= 0.28.0'
  spec.add_development_dependency 'simplecov', '>= 0.9.1'
end
