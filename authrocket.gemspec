# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'authrocket/api/version'

Gem::Specification.new do |gem|
  gem.name          = "authrocket"
  gem.version       = AuthRocket::VERSION
  gem.authors       = ["thomas morgan"]
  gem.email         = ["hello@authrocket.com"]
  gem.description   = %q{AuthRocket client for Ruby.}
  gem.summary       = %q{AuthRocket client for Ruby}
  gem.homepage      = 'https://authrocket.com/'
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'ncore', '~> 1.0'

  gem.add_development_dependency "bundler", "~> 1.3"
  gem.add_development_dependency "rake"
end
