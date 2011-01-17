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
    
    def unload(name = :default)
      return unless cache.key?(name)
      cache[name][:constants].reject! do |const|
        Object.send(:remove_const, const) if Object.const_defined?(const)
      end
      cache[name][:features].reject! do |feature|
        $LOADED_FEATURES.delete(feature)
      end
      cache[name]
    end
    
    def reload(name = :default, &block)
      unload(name)
      load(name, &block)
    end
    
    def cache
      @cache ||= {}
    end
  end
end
