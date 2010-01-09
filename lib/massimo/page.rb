module Massimo
  class Page < Massimo::View
    META_SEP = %r/\A---\s*(?:\r\n|\n)?\z/ # :nodoc:
    
    processable!
    
    # Creates a new page associated with the given file path.
    def initialize(source_path)
      super(source_path, {
        :title     => File.basename(source_path).gsub(File.extname(source_path), "").titleize, 
        :extension => ".html",
        :url       => source_path.gsub(self.class.dir, "").gsub(File.extname(source_path), "").dasherize,
        :layout    => "application"
      })
    end
    
    # Override render to wrap the result in the layout
    def render(use_layout = true)
      output = super()
      if use_layout and found_layout = find_layout
        output = found_layout.render(:page => self) { output }
      end
      output
    end
    
    # Override to_s so that the layout can include the page with `<%= page %>`
    def to_s
      render(false)
    end
    
    protected
    
      # Reads the source page file, and populates the `@meta_data` and
      # `@body` attributes.
      def read_source!
        # read the source file and setup some values for the loop
        source       = super()
        @line        = nil
        front_matter = false
        meta_data    = ""
        body         = ""
        
        # Loop through source to get meta data
        # and the correct line number for the body
        source.each_with_index do |line, line_num|
          if line =~ META_SEP
            front_matter = !front_matter
          else
            if front_matter
              meta_data << line
            else
              @line ||= line_num
              body   << line
            end
          end
        end
        
        # finally get the meta_data as a hash and set the body
        meta_data = YAML.load(meta_data)
        @meta_data.merge!(meta_data.symbolize_keys) if meta_data
        @body = body
      end
      
      # Determine the output file path
      def output_path
        @output_path ||= begin
          path  = site.output_dir(url)
          path << if index? or not html?
              extension unless path.match(/#{extension}$/)
            else
              "/index.html" unless path.match(/\/index\.html$/)
            end
          Pathname.new(path)
        end
      end
      
      # Determines if this is an index page
      def index?
        @source_path.basename.to_s =~ /^index/
      end
      
      # Determines if this an HTML page.
      def html?
        extension =~ /(html|php)$/
      end
      
      # Finds the Layout View if it exists
      def find_layout
        site.find_view("layouts/#{layout}") unless layout == false
      end
  end
end
