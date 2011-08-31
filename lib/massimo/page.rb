require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/string/starts_ends_with'
require 'active_support/inflector'
require 'tilt'
require 'yaml'

module Massimo
  class Page < Resource
    FRONT_MATTER_PARSER = /
      (
        \A\s*       # Beginning of file
        ^---\s*$\n* # Start YAML Block
        (.*?)\n*    # YAML data
        ^---\s*$\n* # End YAML Block
      )
      (.*)          # Rest of File
    /mx

    def render
      output = super
        
      if found_layout = Massimo::View.find("layouts/#{layout}")
        output = found_layout.render(:page => self) { output }
      end
      
      output
    end
    
    def title
      @meta_data[:title] ||= filename.gsub(/\.[^.]+/, '').titleize
    end
    
    def extension
      if @meta_data[:extension]
        @meta_data[:extension]
      elsif Tilt.registered?(super[1..-1])
        '.html'
      else
        super
      end
    end
    
    def url
      @meta_data[:url] ||= super.chomp('index.html').sub(/\.html$/, '/')
    end
    
    def layout
      @meta_data[:layout] = 'main' if @meta_data[:layout].nil?
      @meta_data[:layout]
    end
    
    def output_path
      @output_path ||= begin
        output_path = super.to_s
        output_path << 'index.html' if output_path.ends_with? '/'
        Pathname.new output_path
      end
    end
    
    protected
    
      def template_locals
        @meta_data.merge self.class.resource_name.singularize.to_sym => self
      end
    
      def read_source
        super
        
        case source_path.extname
        when '.yml', '.yaml'
          @meta_data = load_yaml_data @content
          @content   = @meta_data[:content] || ''
        else
          if FRONT_MATTER_PARSER.match @content
            @line      = $1.lines.count + 1
            @meta_data = load_yaml_data $2
            @content   = $3
          end
        end
        
        @meta_data ||= {}
      end
      
      def load_yaml_data(data)
        begin
          (YAML.load(data) || {}).symbolize_keys
        rescue => e
          raise "Error loading front matter from #{source_path}: #{e.message}"
        end
      end
    
      def method_missing(method, *args, &block)
        if args.length == 0
          method_name = method.to_s
          if method_name.chomp! '?'
            !!@meta_data[method_name.to_sym]
          else
            @meta_data[method_name.to_sym]
          end
        else
          super
        end
      end
  end
end