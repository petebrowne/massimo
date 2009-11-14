$:.unshift File.dirname(__FILE__) # For use/testing when no gem is installed

# Rubygems
require "rubygems"

# External
require "pathname"
require "fileutils"
require "yaml"
require "active_support"
require "sprockets"
require "jsmin"

# Internal
require "massimo/filters"
require "massimo/site"
require "massimo/resource"
require "massimo/view"
require "massimo/page"
require "massimo/stylesheet"
require "massimo/javascript"

module Massimo # :nodoc:
  VERSION = File.read(File.join(File.dirname(__FILE__), *%w{.. VERSION}))
  
  MissingResource = Class.new(StandardError)
  InvalidResource = Class.new(StandardError)
end

# Filters
require "massimo/filters/erb"
require "massimo/filters/haml"
require "massimo/filters/ruby"
require "massimo/filters/textile"
require "massimo/filters/markdown"