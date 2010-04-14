require 'yaml'

module Massimo
  class Config
    attr_accessor :source_path, :output_path, :pages_path, :views_path,
                  :pages_url
    
    def initialize(options = nil)
      @source_path = '.'
      @output_path = File.join('.', 'public')
      
      options = YAML.load_file(options) if options.is_a?(String)
      
      options.each do |key, value|
        instance_variable_set "@#{key}", value
      end if options.is_a? Hash
    end
    
    def path_for(resource_name)
      if resource_path = instance_variable_get("@#{resource_name}_path")
        resource_path
      else
        File.join(source_path, resource_name)
      end
    end
    
    def url_for(resource_name)
      if resource_url = instance_variable_get("@#{resource_name}_url")
        resource_url
      else
        '/'
      end
    end
  end
end
