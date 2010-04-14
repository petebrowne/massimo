require 'active_support/inflector'
require 'yaml'

module Massimo
  class Page < Resource
    def render
      read_source
      template = Tilt.new(source_path.basename.to_s, @line || 1) { content }
      template.render
    end
    
    def title
      read_source
      @meta_data['title'] ||= source_path.basename.to_s.chomp(source_path.extname.to_s).titleize
    end
    
    def extension
      read_source
      @meta_data['extension'] ||= '.html'
    end
    
    def url
      read_source
      @meta_data['url'] ||= begin
        url = source_path.to_s.sub(self.class.path, '')
        url = url.chomp(source_path.extname.to_s).dasherize
        url = File.join(self.class.url, url) unless url[self.class.url]
        url
      end
      @meta_data['url'] = '/' + @meta_data['url'] unless @meta_data['url'][/^\//]
      @meta_data['url']
    end
    
    def layout
      read_source
      @meta_data['layout'] ||= 'application'
    end
    
    protected
    
      def read_source
        return if defined? @content
        
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
        
        @meta_data = YAML.load(meta_data) || {}
      end
      
      def method_missing(method, *args, &block)
        method_name = method.to_s
        case args.length
        when 1
          if method_name.chomp! '='
            read_source
            @meta_data[method_name] = args.first
          else
            super
          end
        when 0
          read_source
          @meta_data[method_name]
        else
          super
        end
      end
  end
end
