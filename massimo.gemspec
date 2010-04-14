# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = 'massimo'
  s.version     = File.read File.expand_path('../VERSION', __FILE__)
  s.summary     = 'Massimo is a static website builder.'
  s.description = 'Massimo builds HTML, Javascript, and CSS Files from your source.'
  
  s.authors  = 'Pete Browne'
  s.email    = 'me@petebrowne.com'
  s.homepage = 'http://github.com/petebrowne/massimo'
  
  s.files       = Dir['{bin,lib}/**/*'] + %w(LICENSE README.md VERSION)
  s.executables << 'massimo'
  
  s.add_dependency 'activesupport', '>= 3.0.0.beta'
  s.add_dependency 'tilt',          '~> 0.8.0'
  
  s.add_development_dependency 'version',        '~> 0.9.0'
  s.add_development_dependency 'rspec',          '~> 1.3.0'
  s.add_development_dependency 'test-construct', '~> 1.2.0'
  s.add_development_dependency 'rr',             '~> 0.10.0'
  s.add_development_dependency 'unindent',       '~> 0.9.0'
end
