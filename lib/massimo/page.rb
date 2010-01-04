module Massimo
  class Page < View
    META_SEP = %r/\A---\s*(?:\r\n|\n)?\z/ # :nodoc:
    
    # Creates a new page associated with the given file path.
    def initialize(source_path)
      super(source_path, {
        :title     => ::File.basename(source_path).gsub(::File.extname(source_path), "").titleize, 
        :extension => ".html",
        :url       => source_path.gsub(site.pages_dir, "").gsub(::File.extname(source_path), "").dasherize,
        :layout    => "application"
      })
    end
    
    # Override render to wrap the result in the layout
    def render(with_layout = true)
      output = super()
      output = find_layout.render(:page => self) { output } if with_layout && find_layout
      output
    end
    
    # Writes the filtered data to the output file.
    def process!
      refresh_layout
      # Make the full path to the directory of the output file
      ::FileUtils.mkdir_p(output_path.dirname)
      # write the filtered data to the output file
      output_path.open("w") do |file|
        file.write render(layout?)
      end
    end
    
    # Override to_s so that the layout can include the page with <%= page %>
    def to_s
      render(false)
    end
    
    protected
    
      # Reads the source page file, and populates the meta_data and
      # body attributes.
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
        meta_data = ::YAML.load(meta_data)
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
          ::Pathname.new(path)
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
      
      # The next time `find_layout` is called, the layout will be reloaded.
      def refresh_layout
        @layout_view = nil
      end
      
      # Determines if there's a layout associated with this page.
      def layout?
        layout != false && !find_layout.nil?
      end
      
      # Finds the Layout View if it exists
      def find_layout
        @layout_view ||= site.find_view("layouts/#{layout}") unless layout == false
      end
  end
end
