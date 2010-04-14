require 'active_support/inflector'
require 'fileutils'
require 'pathname'

module Massimo
  class Resource
    class << self
      def resource_name
        self.name.underscore.sub(/.*\//, '').pluralize
      end
      
      def path
        Massimo.config.path_for resource_name
      end
      
      def url
        Massimo.config.url_for resource_name
      end
    end
    
    attr_reader :source_path
    
    def initialize(source)
      @source_path = source.is_a?(Pathname) ? source : Pathname.new(source)
    end
    
    # The path to the output file.
    def output_path
      @output_path ||= Pathname.new source_path.to_s.sub(/^#{Massimo.config.source_path}/, Massimo.config.output_path)
    end
    
    # Reads the associated file's content.
    def content
      read_source
      @content
    end
    
    # Runs the content through any necessary filters, templates, etc.
    def render
      content
    end
    
    # Writes the rendered content to the output file.
    def process
      FileUtils.mkdir_p(output_path.dirname)
      output_path.open('w') do |f|
        f.write render
      end
    end
    
    protected
    
      def read_source
        return if defined? @content
        @content = source_path.read
      end
  end
end
