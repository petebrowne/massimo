module Massimo
  autoload :CLI,        'massimo/cli'
  autoload :Config,     'massimo/config'
  autoload :Helpers,    'massimo/helpers'
  autoload :Javascript, 'massimo/javascript'
  autoload :Page,       'massimo/page'
  autoload :Resource,   'massimo/resource'
  autoload :Server,     'massimo/server'
  autoload :Site,       'massimo/site'
  autoload :Stylesheet, 'massimo/stylesheet'
  autoload :UI,         'massimo/ui'
  autoload :View,       'massimo/view'
  autoload :Watcher,    'massimo/watcher'
  
  VERSION = '0.6.5'
  
  class << self
    def site
      @site ||= Site.new
    end
  
    def site=(site)
      @site = site
    end
    
    def config
      site.config
    end
  end
end
