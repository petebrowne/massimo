module Massimo
  class Stylesheet < Resource
    # Render the css based on the type of resource
    def render
      case resource_type.to_sym
      when :css
        @body.to_s
      when :sass
        require "sass" unless defined? ::Sass
        ::Sass::Files.tree_for(@source_path, sass_options).render
      when :less
        require "less" unless defined? ::Less
        ::Less.parse(@body)
      end
    end
    
    # Writes the rendered css to the output file.
    def process!
      # Make the full path to the directory of the output file
      ::FileUtils.mkdir_p(self.output_path.dirname)
      # write the filtered data to the output file
      self.output_path.open("w") do |file|
        file.write self.render
      end
    end
    
    protected
      
      # Determine the output file path
      def output_path
        @output_path ||= ::Pathname.new(@source_path.to_s.
          sub(self.site.source_dir, self.site.output_dir). # move to output dir
          sub(/#{@source_path.extname}$/, ".css")) # replace extension with .css
      end
      
      # Gets the Sass options, with Site options merged in.
      def sass_options
        {
          :style => site.production? ? :compressed : :nested
        }.merge(self.site.options[:sass]).
          merge(:css_filename => self.output_path)
      end
    
  end
end