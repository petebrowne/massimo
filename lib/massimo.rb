libdir = ::File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

# Rubygems
require "rubygems"

# External
require "pathname"
require "fileutils"
require "yaml"
require "singleton"
require "active_support"
require "sinatra_more"
require "sprockets"
require "jsmin"
require "tilt"

# Internal
require "massimo/helpers"
require "massimo/templates"
require "massimo/site"
require "massimo/resource"
require "massimo/view"
require "massimo/page"
require "massimo/stylesheet"
require "massimo/javascript"

module Massimo
  VERSION = ::File.read(::File.join(::File.dirname(__FILE__), *%w{.. VERSION})) # :nodoc:
  
  MissingResource = ::Class.new(StandardError) # :nodoc:
  InvalidResource = ::Class.new(StandardError) # :nodoc:
  
  #
  def self.Site(options = {})
    return @site if defined?(@site) && options.empty?
    @site = ::Massimo::Site.instance.setup(options)
  end
end
