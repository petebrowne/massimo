require 'active_support/core_ext/string/starts_ends_with'
require 'active_support/inflector'
require 'active_support/memoizable'
require 'fileutils'
require 'pathname'
require 'tilt'

module Massimo
  class Resource
    extend ActiveSupport::Memoizable
    
    class << self
      # The underscored, pluralized name of the resource.
      def resource_name
        self.name.underscore.sub(/.*\//, '').pluralize
      end
      
      # The path to the resource's directory.
      def path
        Massimo.config.path_for resource_name
      end
      
      # The base url for the resource.
      def url
        Massimo.config.url_for resource_name
      end
      
      # Finds a Resource by the given name.
      def find(name)
        resource_path = Dir.glob(File.join(path, "#{name}.*")).first
        resource_path && self.new(resource_path)
      end
      
      # Finds all the Resources in the resource's directory.
      def all
        files = Massimo.config.files_in resource_name
        files.reject! { |file| File.basename(file).starts_with?('_') }
        files.map { |file| self.new(file) }
      end
      
      # Whether or not massimo should process the resource's files.
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
    
    # Creates a new resource for the given source file.
    # The contents of the file will automatically be read.
    def initialize(source)
      @source_path = Pathname.new(source).expand_path
      read_source
    end
    
    # The basename of the source file.
    def filename
      source_path.basename.to_s
    end
    
    # The extension to output with.
    def extension
      extensions.first
    end
    
    # A list of all the extensions appended to the filename.
    def extensions
      filename.scan /\.[^.]+/
    end
    
    # The url to the resource. This is created by swiching the base path
    # of the source file with the base url.
    def url
      url = source_path.to_s.sub(/^#{Regexp.escape(self.class.path)}/, '')
      url = url.sub(/\..+$/, extension)
      url = File.join(self.class.url, url) unless url.starts_with? self.class.url
      url = url.dasherize
      url
    end
    
    # The path to the output file.
    def output_path
      Pathname.new File.join(Massimo.config.output_path, url.sub(/^#{Regexp.escape(Massimo.config.base_url)}/, ''))
    end
    
    # Runs the content through any necessary filters, templates, etc.
    def render
      extensions.reverse.inject(content) do |output, ext|
        if template_type = Tilt[ext]
          template_options = Massimo.config.options_for(ext[1..-1])
          template         = template_type.new(source_path.to_s, @line, template_options) { output }
          template.render(template_scope, template_locals)
        else
          output
        end
      end
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
      
      def template_scope
        Massimo.site.template_scope
      end
      
      def template_locals
        {}
      end
      
      memoize :filename, :extension, :extensions, :url, :output_path
  end
end