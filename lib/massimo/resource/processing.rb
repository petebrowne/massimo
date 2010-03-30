require "fileutils"
require "pathname"

module Massimo
  module Resource
    module Processing
      def self.included(base) # :nodoc:
        base.extend ClassMethods
      end
      
      module ClassMethods
        # Determine if this Resource type is processable. By default this is `false`.
        def processable?
          false
        end
    
        # This will override `processable?` to return `true`.
        def processable!
          def self.processable?
            true
          end
        end
        
        # Process all the Resources in this Resource type's directory.
        def process!
          all(true).each(&:process!)
        end
      end
      
      # Writes the rendered body to the output file.
      def process!
        if self.class.processable?
          # Make the full path to the directory of the output file
          FileUtils.mkdir_p(output_path.dirname)
          # write the filtered data to the output file
          output_path.open("w") do |file|
            file.write render
          end
        else
          false
        end
      end
      
      protected
    
        # Reads the source page file, and populates the `@meta_data` and
        # `@body` attributes.
        def read_source!
          raise Massimo::MissingResource unless @source_path.exist?
          # try to read it now
          begin
            @line = 1
            @body = @source_path.read
          rescue
            raise Massimo::InvalidResource
          end
        end
      
        # Determine the output file path
        def output_path
          @output_path ||= Pathname.new(
            @source_path.to_s.sub(site.source_dir, site.output_dir)
          )
        end
    end
  end
end
