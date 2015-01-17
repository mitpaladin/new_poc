
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'newpoc/entity/user/version'

Gem::Specification.new do |spec|
  spec.name          = "newpoc-entity-user"
  spec.version       = Newpoc::Entity::User::VERSION
  spec.authors       = ["Jeff Dickey"]
  spec.email         = ["jdickey@seven-sigma.com"]
  spec.summary       = %q{User Entity implementation for `newpoc`.}
  spec.description   = %q{User Entity implementation for `newpoc`.}
  spec.homepage      = "https://github.com/jdickey/new_poc/"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rubocop", ">= 0.28.0"
  spec.add_development_dependency "simplecov", ">= 0.9.1"
 end
