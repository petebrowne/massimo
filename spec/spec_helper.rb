lib = File.expand_path('../../lib', __FILE__)
$:.unshift(lib) unless $:.include?(lib)

require 'rubygems'
require 'bundler'
Bundler.require(:default, :development)
require 'massimo'

Spec::Runner.configure do |config|
  config.include Construct::Helpers
  config.include Rack::Test::Methods
  config.mock_with :rr
  
  config.before :each do
    stub($stdout)
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
