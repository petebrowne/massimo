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
      @source_path = source.is_a?(Pathname) ? source.expand_path : Pathname.new(source).expand_path
    end
    
    def url
      @url ||= begin
        puts self.class.path.inspect
        puts source_path.to_s.inspect
        url = source_path.to_s.sub(/^#{Regexp.escape(self.class.path)}/, '')
        if directory_index?
          url.chomp! File.basename(url)
        else
          url.sub! /\.[^\.]+$/, extension
        end
        url = url.dasherize
        url = File.join(self.class.url, url) unless url[self.class.url]
        url
      end
    end
    
    def extension
      source_path.extname
    end
    
    # The path to the output file.
    def output_path
      @output_path ||= Pathname.new File.join(Massimo.config.output_path, url)
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
      
      def directory_index?
        Massimo.config.directory_index.include? source_path.basename.to_s
      end
  end
end
