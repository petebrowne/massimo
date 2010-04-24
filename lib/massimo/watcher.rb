module Massimo
  class Watcher
    class << self
      def start(site)
        self.new(site).run
      end
    end
    
    def initialize(site)
      @site  = site
      @files = []
    end
    
    def run
      loop do
        process
        sleep 0.5
      end
    end
    
    def process
      if changed?
        begin
          puts 'massimo has noticed a change'
          @site.process
          puts 'massimo has built your site'
        rescue Exception => e
          puts e.message
          puts e.backtrace
        end
      end
    end
    
    def changed?
      @files != files
    end
    
    protected
    
      def files
        @files = Dir[*glob].map { |file| File.mtime(file) }
      end
      
      def glob
        glob  = @site.resources.map(&:path)
        glob << @site.config.path_for(:lib)
        glob << @site.config.path_for(:helpers)
        glob.map! { |path| File.join(path, '**/*.*') }
        glob
      end
  end
end
