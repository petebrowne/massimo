lib = File.expand_path('../lib/', __FILE__)
$:.unshift(lib) unless $:.include?(lib)

require 'massimo'
require 'bundler'

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
  
  s.add_bundler_dependencies
end
