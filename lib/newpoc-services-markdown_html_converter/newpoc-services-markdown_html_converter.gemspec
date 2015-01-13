
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'newpoc/services/markdown_html_converter/version'

Gem::Specification.new do |spec|
  spec.name          = "newpoc-services-markdown_html_converter"
  spec.version       = Newpoc::Services::MarkdownHtmlConverter::VERSION
  spec.authors       = ["Jeff Dickey"]
  spec.email         = ["jdickey@seven-sigma.com"]
  spec.summary       = %q{Markdown-to-HTML converter for 'newpoc'.}
  spec.description   = %q{Markdown-to-HTML converter for 'newpoc'.}
  spec.homepage      = "https://github.com/jdickey/new_poc"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'html-pipeline', '~> 1.11'
  spec.add_dependency 'gemoji', '~> 2.1'
  spec.add_dependency 'github-linguist', '~> 4.2', '>= 4.2.5'
  spec.add_dependency 'github-markdown', '~> 0.6', '>= 0.6.8'
  spec.add_dependency 'pygments.rb', '~> 0.5', '>= 0.5.4'
# gem 'pygments.rb', github: 'lencioni/pygments.rb', branch: 'yajl-update'
  spec.add_dependency 'rinku', '~> 1.7', '>= 1.7.3'
  spec.add_dependency 'sanitize', '~> 3.1'
  spec.add_dependency 'yajl-ruby', '~> 1.1'

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency 'chronic', '>= 0.10.2'
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.1"
  spec.add_development_dependency "rubocop", ">= 0.28.0"
  spec.add_development_dependency "simplecov", ">= 0.9.1"
  spec.add_development_dependency 'fancy-open-struct', '>= 0.4.0'
  spec.add_development_dependency 'pry-byebug'
end
