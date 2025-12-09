# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'authrocket/api/version'

Gem::Specification.new do |spec|
  spec.name          = "authrocket"
  spec.version       = AuthRocket::VERSION
  spec.authors       = ["AuthRocket Team"]
  spec.email         = ["hello@authrocket.com"]
  spec.description   = %q{AuthRocket client for Ruby.}
  spec.summary       = %q{AuthRocket client for Ruby}
  spec.homepage      = 'https://authrocket.com/'
  spec.license       = 'MIT'

  spec.metadata = {
    'source_code_uri' => 'https://github.com/authrocket/authrocket-ruby',
    'changelog_uri' => 'https://github.com/authrocket/authrocket-ruby/blob/master/CHANGELOG.md'
  }

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.7'

  spec.add_dependency 'addressable', '~> 2.5'
  spec.add_dependency 'ncore', '~> 3.10'
  spec.add_dependency 'jwt', '~> 3.1'

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
end
