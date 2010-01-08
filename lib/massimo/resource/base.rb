require File.join(File.dirname(__FILE__), "processing")
require File.join(File.dirname(__FILE__), "collection")

module Massimo
  module Resource
    class Base
      include Massimo::Resource::Processing
      extend  Massimo::Resource::Collection
    
      attr_reader :source_path, :body
    
      # Get the name of this Resource type.
      def self.name
        self.to_s.underscore.gsub(/.*\//, "")
      end
    
      # Gets the site instance
      def self.site
        Massimo::Site()
      end
    
      # Get the directory to this Resource type.
      def self.dir(*path)
        site.dir_for(self.name.to_s.pluralize, *path)
      end
    
      # Hook for adding Resource types.
      def self.inherited(subclass)
        Massimo.resources << subclass
      end
    
      # Creates a new page associated with the given file path.
      def initialize(source_path)
        @source_path = Pathname.new(source_path)
        read_source!
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
        self.class.site
      end
    
      # Renders the page using the registered filters.
      def render(locals = {})
        @body
      end
    
      protected
      
        # Get the options from the Site's config for the current resource type.
        def options_for_resource_type
          site.options[resource_type.to_sym]
        end
    end
  end
end
