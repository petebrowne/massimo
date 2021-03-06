# -*- encoding: utf-8 -*-
require File.expand_path('../lib/massimo/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'massimo'
  s.version     = Massimo::VERSION
  s.summary     = 'Massimo is a static website builder.'
  s.description = 'Massimo builds HTML, Javascript, and CSS Files from your source.'
  
  s.authors           = ['Pete Browne']
  s.email             = ['me@petebrowne.com']
  s.homepage          = 'http://massimo.petebrowne.com/'
  s.rubyforge_project = 'massimo'
  
  s.add_dependency             'activesupport',    '~> 3.0'
  s.add_dependency             'i18n',             '~> 0.4'
  s.add_dependency             'rack',             '~> 1.1'
  s.add_dependency             'padrino-helpers',  '~> 0.9'
  s.add_dependency             'thor',             '~> 0.14'
  s.add_dependency             'tilt',             '~> 1.3'
  s.add_dependency             'crush',            '~> 0.3'
  s.add_dependency             'tzinfo',           '~> 0.3'
  s.add_dependency             'sprockets',        '~> 1.0'
  s.add_development_dependency 'rake',             '>= 0.8.7'
  s.add_development_dependency 'rspec',            '~> 2.6'
  s.add_development_dependency 'rr',               '~> 1.0'
  s.add_development_dependency 'test-construct',   '~> 1.2'
  s.add_development_dependency 'rack-test',        '~> 0.5'
  s.add_development_dependency 'unindent',         '~> 0.9'
  s.add_development_dependency 'haml',             '~> 3.1'
  s.add_development_dependency 'sass',             '~> 3.1'
  s.add_development_dependency 'less',             '~> 1.2'

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{ |f| f =~ /^bin\/(.*)/ ? $1 : nil }.compact
  s.require_path = 'lib'
end
