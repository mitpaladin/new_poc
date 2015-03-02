
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'newpoc/action/post/update/version'

Gem::Specification.new do |spec|
  spec.name          = 'newpoc-action-post-update'
  spec.version       = Newpoc::Action::Post::Update::VERSION
  spec.authors       = ['Jeff Dickey']
  spec.email         = ['jdickey@seven-sigma.com']
  spec.summary       = %q{Verifies that the current user is permitted to update a specified post.}
  spec.description   = %q{Verifies that the current user is permitted to edit a specified post. Part of `new_poc`.}
  spec.homepage      = 'https://github.com/jdickey/new_poc'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'wisper', '~> 1.6'
  spec.add_dependency 'yajl-ruby', '~> 1.2'
  spec.add_dependency 'cabin'

  spec.add_development_dependency 'wisper_subscription', '>= 0.2.0'
  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop', '>= 0.28.0'
  spec.add_development_dependency 'simplecov', '>= 0.9.1'
  spec.add_development_dependency 'fancy-open-struct', '>= 0.4.0'
  spec.add_development_dependency 'pry-byebug'
end