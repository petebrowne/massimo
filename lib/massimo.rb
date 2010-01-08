# Rubygems
require "rubygems"

# External
require "pathname"
require "fileutils"
require "singleton"
require "active_support"
require "sinatra_more"
require "sprockets"
require "jsmin"
require "tilt"

# Internal
lib_dir = File.dirname(__FILE__)
require File.join(lib_dir, "massimo", "helpers")
require File.join(lib_dir, "massimo", "templates")
require File.join(lib_dir, "massimo", "site")

module Massimo
  VERSION = File.read(File.join(File.dirname(__FILE__), "..", "VERSION")) # :nodoc:
  
  MissingResource = Class.new(StandardError) # :nodoc:
  InvalidResource = Class.new(StandardError) # :nodoc:
  
  # This will create an instance of Massimo::Site the first time it is called.
  # Everytime it's called afterwords, without options, it returns the same
  # instance.
  def self.Site(options = {})
    return @site if defined?(@site) && options.empty?
    @site = Massimo::Site.instance.setup(options)
  end
  
  # All the avaiable Resource types
  def self.resources
    @resources ||= []
  end
  
  # All the Resource types that are processable.
  def self.processable_resources
    resources.select { |resource| resource.processable? }
  end
end

require File.join(lib_dir, "massimo", "resource", "base")
require File.join(lib_dir, "massimo", "view")
require File.join(lib_dir, "massimo", "page")
require File.join(lib_dir, "massimo", "stylesheet")
require File.join(lib_dir, "massimo", "javascript")
