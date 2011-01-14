module Massimo
  module Reloader
    extend self
    
    def load(name = :default)
      cache[name] ||= {}
      
      previous_constants = Object.constants
      previous_features  = $LOADED_FEATURES.dup
      yield if block_given?
      cache[name][:constants] = (Object.constants - previous_constants).uniq
      cache[name][:features]  = ($LOADED_FEATURES - previous_features).uniq
      
      cache[name]
    end
    
    def unload(name = :default, &block)
      
    end
    
    def reload(name = :default, &block)
      
    end
    
    def cache
      @cache ||= {}
    end
  end
end
