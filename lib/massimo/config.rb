require 'yaml'

module Massimo
  class Config
    attr_accessor :source_path, :output_path
    
    def initialize(options = nil)
      @source_path = '.'
      @output_path = File.join('.', 'public')
      
      options = YAML.load_file(options) if options.is_a?(String)
      
      options.each do |key, value|
        instance_variable_set "@#{key}", value
      end if options.is_a? Hash
    end
  end
end
