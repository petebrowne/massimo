require 'active_support/core_ext/string/starts_ends_with'

module Massimo
  module Commands
    class Server < Base
      def banner
%{
#{Massimo::UI.color('massimo server [PORT]', :cyan)}
Runs a local Rack based web server on the given port.
}
      end
      
      def add_options
        if ARGV.first && !ARGV.first.starts_with?('-')
          @port = ARGV.shift
        end
      end
      
      def run
        Massimo::Server.start(site, (@port || 3000).to_i)
      end
    end
  end
end
