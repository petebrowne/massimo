require 'active_support/core_ext/hash/keys'
require 'ostruct'
require 'yaml'

module Massimo
  class Config < OpenStruct
    DEFAULT_OPTIONS = {
      :source_path     => '.',
      :output_path     => 'public',
      :resources_path  => '.',
      :base_url        => '/',
      :resources_url   => '/',
      :javascripts_url => '/javascripts',
      :stylesheets_url => '/stylesheets'
    }.freeze
    
    # Creates a new configuration. Takes either a hash of options
    # or a file path to a .yaml file.
    def initialize(options = nil)
      hash = DEFAULT_OPTIONS.dup
      
      options = YAML.load_file(options) if options.is_a? String
      hash.merge!(options.symbolize_keys) if options.is_a? Hash
      
      super hash
    end
    
    # The full, expanded path to the source path.
    def source_path
      File.expand_path super
    end
    
    # The full, expanded path to the output path.
    def output_path
      File.expand_path super
    end
    
    # Get a full, expanded path for the given resource name. This is either set
    # in the configuration or determined dynamically based on the name.
    def path_for(resource_name)
      if resource_path = send("#{resource_name}_path")
        File.expand_path resource_path
      else
        File.join source_path, resource_name.to_s
      end
    end
    
    # Get the configured URL for th given resource name.
    def url_for(resource_name)
      File.join base_url, send("#{resource_name}_url") || resources_url
    end
    
    # Get an array of all the file paths found in the given resource name's path,
    # restricted to the given extension.
    def files_in(resource_name, extension = '*')
      Dir.glob File.join(path_for(resource_name), "**/*.#{extension}")
    end
    
    # Convience method for getting options for a given library name. For instance,
    # this is how we get the options set for Haml or Sass during processing.
    def options_for(lib_name)
      send(lib_name) || {}
    end
    
    # Wether or not the Site's environment is in production mode. Usually you would
    # want to set this to compress and concat assets.
    def production?
      !!self.production
    end
  end
end
