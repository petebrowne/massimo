require 'rack'

module Massimo
  class Server
    class << self
      def start(site, port = 3000)
        app = Rack::Builder.new do
          use Rack::ShowExceptions
          run Massimo::Server.new(site)
        end
        Rack::Handler::WEBrick.run(app, :Port => port)
      end
    end
    
    def initialize(site)
      @site        = site
      @file_server = Rack::File.new(site.config.output_path)
      @watcher     = Massimo::Watcher.new(site)
    end
    
    def call(env)
      @watcher.process
      env['PATH_INFO'] << 'index.html' if env['PATH_INFO'] =~ /\/$/
      @file_server.call(env)
    end
  end
end