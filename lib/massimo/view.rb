require "tilt"
require "massimo/resource/base"

module Massimo
  class View < Massimo::Resource::Base
    attr_reader :meta_data
    
    # Creates a new page associated with the given file path.
    def initialize(source_path, meta_data = {})
      @meta_data = meta_data
      super(source_path)
    end
    
    # Renders the page using the appropriate Tilt Template
    def render(locals = {}, &block)
      template = Tilt.new(file_name, @line || 1, options_for_resource_type) { @body }
      template.render(site.helpers, @meta_data.merge(locals), &block)
    end
    
    protected
      
      # All undefined methods are sent to the `@meta_data` hash.
      def method_missing(method, *args, &block)
        case args.length
        when 1
          method_name = method.to_s
          if method_name.chomp!('=')
            @meta_data[method_name.to_sym] = args.first
          else
            super
          end
        when 0
          @meta_data[method]
        else
          super
        end
      end
  end
end
