module Massimo
  class Site
    attr_accessor :config
    
    def initialize(options = nil)
      @config = Config.new(options)
      yield @config if block_given?
      Massimo.site = self
    end
  end
end
