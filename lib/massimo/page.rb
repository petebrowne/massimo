require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/string/starts_ends_with'
require 'active_support/inflector'
require 'tilt'
require 'yaml'

module Massimo
  class Page < Resource
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
        case source_path.extname
        when '.yml', '.yaml'
          @meta_data = (YAML.load(source_path.read) || {}).symbolize_keys
          @content   = @meta_data[:content] || ''
        else
          @line        = nil
          @content     = ''
          front_matter = false
          meta_data    = ''
        
          source_path.open do |file|
            file.each do |line|
              if line =~ /\A---\s*\Z/
                front_matter = !front_matter
              else
                if front_matter
                  meta_data << line
                else
                  @line ||= file.lineno
                  @content << line
                end
              end
            end
          end
        
          @meta_data = (YAML.load(meta_data) || {}).symbolize_keys
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