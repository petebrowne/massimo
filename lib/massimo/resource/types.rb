module Massimo
  module Resource
    module Types
      # All the avaiable Resource types
      def types
        @types ||= []
      end
    
      # All the Resource types that are processable.
      def processable_types
        types.select { |type| type.processable? }
      end
    
      # Hook for adding Resource types.
      def inherited(subclass)
        ::Massimo::Resource::Base.types << subclass
      end
    end
  end
end
