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
      
      def find(name)
        resource_path = Dir.glob(File.join(path, "#{name}.*")).first
        resource_path && self.new(resource_path)
      end
      
      def all
        files = Massimo.config.files_in resource_name
        files.reject! { |file| File.basename(file) =~ /^_/ }
        files.map { |file| self.new(file) }
      end
      
      def processable?
        true
      end
      
      protected
        
        def unprocessable
          def self.processable?; false; end
          define_method(:process) { false }
        end
    end
    
    attr_reader :source_path, :content
    
    def initialize(source)
      @source_path = source.is_a?(Pathname) ? source.expand_path : Pathname.new(source).expand_path
      read_source
    end
    
    def filename
      @filename ||= source_path.basename.to_s
    end
    
    def extension
      @extension ||= source_path.extname
    end
    
    def url
      @url ||= begin
        url = source_path.to_s.sub(/^#{Regexp.escape(self.class.path)}/, '')
        url = url.sub(/\.[^\.]+$/, extension)
        url = File.join(self.class.url, url) unless url.include? self.class.url
        url = url.dasherize
        url
      end
    end
    
    # The path to the output file.
    def output_path
      @output_path ||= Pathname.new File.join(Massimo.config.output_path, url)
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
        @content = source_path.read
      end
  end
end
