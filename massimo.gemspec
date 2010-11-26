# -*- encoding: utf-8 -*-
require File.expand_path('../lib/massimo/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'massimo'
  s.version     = Massimo::VERSION
  s.summary     = 'Massimo is a static website builder.'
  s.description = 'Massimo builds HTML, Javascript, and CSS Files from your source.'
  
  s.authors           = 'Pete Browne'
  s.email             = 'me@petebrowne.com'
  s.homepage          = 'http://petebrowne.github.com/massimo/'
  s.rubyforge_project = 'massimo'
  
  s.files       = Dir['{bin,lib}/**/*'] + %w(LICENSE README.md)
  s.executables << 'massimo'
  
  s.add_dependency             'activesupport',  '~> 3.0.0'
  s.add_dependency             'i18n',           '~> 0.4.0'
  s.add_dependency             'rack',           '~> 1.2.0'
  s.add_dependency             'sinatra_more',   '~> 0.3.0'
  s.add_dependency             'thor',           '~> 0.14.0'
  s.add_dependency             'tilt',           '~> 1.1.0'
  s.add_dependency             'tzinfo',         '~> 0.3.0'
  s.add_development_dependency 'rspec',          '~> 2.0.0'
  s.add_development_dependency 'rr',             '~> 1.0.0'
  s.add_development_dependency 'test-construct', '~> 1.2.0'
  s.add_development_dependency 'rack-test',      '~> 0.5.0'
  s.add_development_dependency 'unindent',       '~> 0.9.0'
  s.add_development_dependency 'haml',           '~> 3.0.0'
  s.add_development_dependency 'less',           '~> 1.2.0'
  s.add_development_dependency 'coffee-script',  '~> 0.3.0'
  s.add_development_dependency 'sprockets',      '~> 1.0.0'
  s.add_development_dependency 'jsmin',          '~> 1.0.0'
  s.add_development_dependency 'packr',          '~> 3.1.0'
  s.add_development_dependency 'growl',          '~> 1.0.0'
end
