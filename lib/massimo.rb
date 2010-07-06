module Massimo
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
  
  module Commands
    autoload :Base,     'massimo/commands/base'
    autoload :Build,    'massimo/commands/build'
    autoload :Generate, 'massimo/commands/generate'
    autoload :Help,     'massimo/commands/help'
    autoload :Server,   'massimo/commands/server'
    autoload :Version,  'massimo/commands/version'
    autoload :Watch,    'massimo/commands/watch'
  end
  
  VERSION = '0.7.0'
  
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
