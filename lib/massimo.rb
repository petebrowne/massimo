libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require "massimo/helpers"
require "massimo/templates"
require "massimo/site"

module Massimo
  VERSION = File.read(File.expand_path("../../VERSION", __FILE__)) # :nodoc:
  
  MissingResource = Class.new(StandardError) # :nodoc:
  InvalidResource = Class.new(StandardError) # :nodoc:
  
  # This will create an instance of Massimo::Site the first time it is called.
  # Everytime it's called afterwords, without options, it returns the same
  # instance.
  def self.Site(options = {})
    return @site if defined?(@site) && options.empty?
    @site = Site.instance.setup(options)
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

require "massimo/resource/base"
require "massimo/view"
require "massimo/page"
require "massimo/stylesheet"
require "massimo/javascript"
