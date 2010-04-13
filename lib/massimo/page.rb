require 'yaml'

module Massimo
  class Page < Resource
    def meta_data
      read_source
      @meta_data
    end
    
    def render
      read_source
      template = Tilt.new(source_path.basename.to_s, @line || 1) { content }
      template.render
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
  end
end
