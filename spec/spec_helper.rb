$:.unshift File.expand_path('../../lib', __FILE__)

require 'rubygems'
require 'bundler'
Bundler.require(:default, :test)
require 'massimo'

Spec::Runner.configure do |config|
  config.include Construct::Helpers
  config.include Rack::Test::Methods
  config.mock_with :rr
  
  config.after :each do
    Massimo.site = nil
  end
end
