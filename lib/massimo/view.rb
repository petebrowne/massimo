module Massimo
  class View < Resource
    attr_reader :meta_data
    
    # Creates a new page associated with the given file path.
    def initialize(site, source_path, meta_data = {})
      @meta_data = meta_data
      super(site, source_path)
    end
    
    # Renders the page using the registered filters.
    def render(locals = {})
      Massimo.filter(@body, self.resource_type, @site.template, @meta_data.merge(locals))
    end
    
    protected
      
      # All undefined methods are sent to the meta_data hash.
      def method_missing(method, *args, &block)
        if method.to_s.match(/(.*)\=$/) && args.length == 1
          @meta_data[$1.to_sym] = args.first
        elsif args.empty? && @meta_data.key?(method)
          @meta_data[method]
        else
          super
        end
      end
  end
end
