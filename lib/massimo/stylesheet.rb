module Massimo
  class Stylesheet < Massimo::Resource::Base
    processable!
    
    # Render the css based on the type of resource
    def render
      case resource_type.to_sym
      when :sass
        require "sass" unless defined?(Sass)
        Sass::Files.tree_for(@source_path, sass_options).render
      when :less
        require "less" unless defined?(Less)
        Less.parse(@body)
      else
        @body.to_s
      end
    end
    
    protected
      
      # Determine the output file path
      def output_path
        @output_path ||= Pathname.new(@source_path.to_s.
          sub(site.source_dir, site.output_dir). # move to output dir
          sub(/#{@source_path.extname}$/, ".css") # replace extension with .css
        )
      end
      
      # Gets the Sass options, with Site options merged in.
      def sass_options
        options = {
          :style => site.production? ? :compressed : :nested
        }
        options.merge!(site.options[:sass]) if site.options[:sass].is_a?(Hash)
        options.merge(:css_filename => output_path)
      end
    
  end
end