module Massimo
  module Commands
    class Version < Base
      def run
        puts Massimo::VERSION
      end
    end
  end
end
