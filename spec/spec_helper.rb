$:.unshift File.dirname(__FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)

require 'rubygems'
require 'spec'
require 'rr'
require 'construct'
require 'unindent'
require 'massimo'

Spec::Runner.configure do |config|
  config.include Construct::Helpers
  config.mock_with :rr
  
  config.after :each do
    Massimo.site = nil
  end
end
