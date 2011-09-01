require 'massimo/version'

module Massimo
  autoload :Config,     'massimo/config'
  autoload :CLI,        'massimo/cli'
  autoload :Helpers,    'massimo/helpers'
  autoload :Javascript, 'massimo/javascript'
  autoload :Page,       'massimo/page'
  autoload :Reloader,   'massimo/reloader'
  autoload :Resource,   'massimo/resource'
  autoload :Server,     'massimo/server'
  autoload :Site,       'massimo/site'
  autoload :Stylesheet, 'massimo/stylesheet'
  autoload :UI,         'massimo/ui'
  autoload :View,       'massimo/view'
  autoload :Watcher,    'massimo/watcher'
  
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
