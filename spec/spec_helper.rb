lib = File.expand_path('../../lib', __FILE__)
$:.unshift(lib) unless $:.include?(lib)

require 'rubygems'
require 'rspec'
require 'rr'
require 'construct'
require 'rack/test'
require 'unindent'
require 'sass'
require 'less'
require 'coffee-script'
require 'sprockets'
require 'jsmin'
require 'packr'
require 'growl'
require 'massimo'

RSpec.configure do |config|
  config.include Construct::Helpers
  config.include Rack::Test::Methods
  config.mock_with :rr
  
  config.before :each do
    stub($stdout).puts
    stub(Growl).notify
  end
  
  config.after :each do
    Massimo.site = nil
  end
  
  def with_file(filename, content = nil)
    within_construct do |construct|
      construct.file filename, content
      yield
    end
  end
end
