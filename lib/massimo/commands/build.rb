module Massimo
  module Commands
    class Build < Base
      def banner
%{
#{Massimo::UI.color('massimo build', :cyan)}
Builds the site from the source files.
}
      end
      
      def run
        Massimo::UI.report_errors do
          site.process
          Massimo::UI.say 'massimo has built your site', :growl => true
        end
      end
    end
  end
end
