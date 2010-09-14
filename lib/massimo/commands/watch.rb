module Massimo
  module Commands
    class Watch < Base
      def banner
%{
#{Massimo::UI.color('massimo watch', :cyan)}
Watches your files for changes and automatically builds the site.
}
      end
      
      def run
        Massimo::Watcher.start(site)
      end
    end
  end
end