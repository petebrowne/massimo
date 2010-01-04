module Massimo
  class Resource
    attr_reader :source_path, :body
    
    # Creates a new page associated with the given file path.
    def initialize(source_path)
      @source_path = ::Pathname.new(source_path)
      # read and parse the source file
      read_source!
    end
    
    # Renders the page using the registered filters.
    def render(locals = {})
      @body
    end
    
    # Writes the rendered js to the output file.
    def process!
      # Make the full path to the directory of the output file
      ::FileUtils.mkdir_p(output_path.dirname)
      # write the filtered data to the output file
      output_path.open("w") do |file|
        file.write render
      end
    end
    
    # Gets the resource's file name.
    def file_name
      @source_path.basename.to_s
    end
    
    # Gets the resource type, based on the file's extension
    def resource_type
      @source_path.extname.to_s[1..-1]
    end
    
    # Gets the site instance
    def site
      ::Massimo::Site()
    end
    
    protected
    
      # Reads the source page file, and populates the meta_data and
      # body attributes.
      def read_source!
        raise ::Massimo::MissingResource unless @source_path.exist?
        # try to read it now
        begin
          @line = 1
          @body = @source_path.read
        rescue
          raise ::Massimo::InvalidResource
        end
      end
      
      # Get the options from the Site's config for the current resource type.
      def options_for_resource_type
        site.options[resource_type.to_sym]
      end
      
      # Determine the output file path
      def output_path
        @output_path ||= ::Pathname.new(@source_path.to_s.
          sub(site.source_dir, site.output_dir)) # move to output dir
      end
  end
end
