require 'active_support/core_ext/hash/keys'
require 'ostruct'
require 'yaml'

module Massimo
  class Config < OpenStruct
    DEFAULT_OPTIONS = {
      :source_path     => '.',
      :output_path     => 'public',
      :resources_path  => '.',
      :resources_url   => '/',
      :javascripts_url => '/javascripts',
      :stylesheets_url => '/stylesheets',
      :resources_url   => '/'
    }.freeze
    
    def initialize(options = nil)
      hash = DEFAULT_OPTIONS.dup
      
      options = YAML.load_file(options) if options.is_a?(String)
      hash.merge!(options.symbolize_keys) if options.is_a?(Hash)
      
      super hash
    end
    
    def source_path
      File.expand_path(super)
    end
    
    def output_path
      File.expand_path(super)
    end
    
    def path_for(resource_name)
      path_method = "#{resource_name}_path"
      if resource_path = (respond_to?(path_method) and send(path_method))
        File.expand_path(resource_path)
      else
        File.join(source_path, resource_name.to_s)
      end
    end
    
    def url_for(resource_name)
      url_method = "#{resource_name}_url"
      if resource_url = (respond_to?(url_method) and send(url_method))
        resource_url
      else
        resources_url
      end
    end
  end
end
