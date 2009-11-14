module Massimo
  class Stylesheet < Resource
    attr_reader :site
    
    #
    def initialize(site, source_path)
      @site = site
      super(source_path)
    end
    
    # Render the css based on the type of resource
    def render
      case resource_type.to_sym
      when :css
        @body.to_s
      when :sass
        require "sass" unless defined? ::Sass
        Sass::Files.tree_for(@source_path, { :css_filename => self.output_path }).render
      when :less
        require "less" unless defined? ::Less
        Less.parse(@body)
      end
    end
    
    # Writes the rendered css to the output file.
    def process!
      # Make the full path to the directory of the output file
      FileUtils.mkdir_p(self.output_path.dirname)
      # write the filtered data to the output file
      self.output_path.open("w") do |file|
        file.write self.render
      end
    end
    
    protected
      
      # Determine the output file path
      def output_path
        @output_path ||= Pathname.new(@source_path.to_s.
          sub(@site.source_dir, @site.output_dir). # move to output dir
          sub(/#{@source_path.extname}$/, ".css")) # replace extension with .css
      end
    
  end
end
