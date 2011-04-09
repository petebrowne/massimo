require 'active_support/core_ext/string/starts_ends_with'
require 'rack'

module Massimo
  class Server
    class << self
      def start(site, port = 3000)
        handler = Rack::Handler.default
        trap(:INT) do
          if handler.respond_to?(:shutdown)
            handler.shutdown
          else
            exit
          end
        end
        handler.run(self.new(site), :Port => port)
      end
    end
    
    def initialize(site = Massimo.site)
      @site        = site
      @file_server = Rack::File.new(site.config.output_path)
      @watcher     = Massimo::Watcher.new(site)
    end
    
    def call(env)
      @watcher.process
      env['PATH_INFO'] << 'index.html' if env['PATH_INFO'].ends_with? '/'
      @file_server.call(env)
    end
  end
end