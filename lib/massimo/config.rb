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
      path_method = "#{resource_name}_path"
      if resource_path = (respond_to?(path_method) and send(path_method))
        resource_path
      else
        File.join(source_path, resource_name)
      end
    end
    
    def url_for(resource_name)
      url_method = "#{resource_name}_url"
      if resource_url = (respond_to?(url_method) and send(url_method))
        resource_url
      else
        '/'
      end
    end
  end
end
