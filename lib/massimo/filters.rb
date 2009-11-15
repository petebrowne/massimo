module Massimo
  
  # Manipulates the given data by passing it through the filter
  # associated with the given extension.
  def self.filter(data, extension, template = nil, locals = {})
    filter = Massimo::Filters.find(extension)
    if filter && filter.respond_to?(:call)
      filter.call(data, template || Massimo::Template.new, locals)
    else
      data.to_s
    end
  end
  
  class Filters
    # Add a filter for the given extensions. This block will be
    # called to manipulate pages with matching extensions.
    def self.register(*extensions, &block)
      # normalize extensions array
      extensions.flatten!
      extensions.compact!
      extensions.map!(&:to_sym)
      # add the block to the filters
      self.filters[extensions] = block unless extensions.empty?
    end
      
    # Find the first filter associated with the given extension.
    def self.find(extension)
      filter = self.filters.find do |key, value|
        case key
        when Array
          key.include?(extension.to_sym)
        when Symbol, String
          key.to_sym == extension.to_sym
        end
      end
      filter.is_a?(Array) ? filter.last : filter
    end
    
    # Gets all the available extensions that are renderable.
    def self.extensions
      self.filters.keys.flatten.compact
    end
    
    protected
    
      # The registered filters.
      def self.filters
        @filters ||= {}
      end
    end
end
