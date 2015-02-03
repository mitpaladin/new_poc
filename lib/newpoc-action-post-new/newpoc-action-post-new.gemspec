
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'newpoc/action/post/new/version'

Gem::Specification.new do |spec|
  spec.name          = "newpoc-action-post-new"
  spec.version       = Newpoc::Action::Post::New::VERSION
  spec.authors       = ["Jeff Dickey"]
  spec.email         = ["jdickey@seven-sigma.com"]
  spec.summary       = %q{New-post (pre-edit-attributes) encapsulation for `new_poc`.}
  spec.description   = %q{Verifies that a registered user IS logged in.}
  spec.homepage      = "https://github.com/jdickey/new_poc/"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'wisper', '~> 1.6'
  spec.add_dependency 'yajl-ruby', '>= 1.2.1'

  spec.add_development_dependency 'wisper_subscription', '>= 0.2.0'
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rubocop", ">= 0.28.0"
  spec.add_development_dependency "simplecov", ">= 0.9.1"
  spec.add_development_dependency 'fancy-open-struct', '>= 0.4.0'
  spec.add_development_dependency 'pry-byebug'
end
