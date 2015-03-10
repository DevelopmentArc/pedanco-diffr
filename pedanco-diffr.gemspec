# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pedanco/diffr/version'

Gem::Specification.new do |spec|
  spec.name          = 'pedanco-diffr'
  spec.version       = Pedanco::Diffr::VERSION
  spec.authors       = ['James Polanco']
  spec.email         = ['james@developmentarc.com']
  spec.summary       = 'Provides a change library for managing system changes.'
  spec.description   = <<-EOM
    Pedanco::Diffr provides a change set management system for tracking changes
    anywhere in the system. Diffr works with both ActiveRecord style changes and
    provides a custom system so that it kind be used in a wider syntax without
    requiring ActiveRecord or ActiveModel.
  EOM

  spec.homepage      = 'https://github.com/DevelopmentArc/pedanco-diffr'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = `git ls-files spec`.split("\x0")
  spec.require_path  = 'lib'

  ### Gem Dependencies
  spec.add_runtime_dependency 'activesupport', '<= 4.2', '>= 3.2'

  ### Development Dependencies
  spec.add_development_dependency 'bundler',  '~> 1.7'
  spec.add_development_dependency 'rake',     '~> 10.0'
  spec.add_development_dependency 'rspec',    '~> 3.2'
end
