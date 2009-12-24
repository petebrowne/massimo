module Massimo
  class Page < View
    META_SEP = %r/\A---\s*(?:\r\n|\n)?\z/ # :nodoc:
    
    # Creates a new page associated with the given file path.
    def initialize(source_path)
      @source_path = ::Pathname.new(source_path)
      @meta_data   = {
        :title     => @source_path.basename.to_s.gsub(@source_path.extname, "").titleize, 
        :extension => ".html",
        :url       => @source_path.to_s.gsub(self.site.pages_dir, "").gsub(@source_path.extname, "").dasherize,
        :layout    => "application"
      }
      # read and parse the source file
      self.read_source!
    end
    
    # Override render to wrap the result in the layout
    def render(with_layout = true)
      if with_layout && layout = self.find_layout
        layout.render(:page => self) { self.render(false) }
      else
        super()
      end
    end
    
    # Writes the filtered data to the output file.
    def process!
      refresh_layout
      path = self.output_path
      # Make the full path to the directory of the output file
      ::FileUtils.mkdir_p(path.dirname)
      # write the filtered data to the output file
      path.open("w") do |file|
        file.write self.render(self.layout?)
      end
    end
    
    # Override to_s so that the layout can include the page with <%= page %>
    def to_s
      self.render(false)
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
        path  = self.site.output_dir(self.url)
        path << if index? or not html?
            self.extension unless path.match(/#{self.extension}$/)
          else
            "/index.html" unless path.match(/\/index\.html$/)
          end
        ::Pathname.new(path)
      end
      
      # Determines if this is an index page
      def index?
        @source_path.basename.to_s =~ /^index/
      end
      
      # Determines if this an HTML page.
      def html?
        self.extension =~ /(html|php)$/
      end
      
      # The next time `find_layout` is called, the layout will be reloaded.
      def refresh_layout
        @layout_view = nil
      end
      
      # Determines if there's a layout associated with this page.
      def layout?
        self.layout != false && !self.find_layout.nil?
      end
      
      # Finds the Layout View if it exists
      def find_layout
        @layout_view ||= self.site.find_view("layouts/#{self.layout}") unless self.layout == false
      end
  end
end
