module Massimo
  class Watcher
    class << self
      def start(site)
        self.new(site).run
      end
    end
    
    def initialize(site)
      @site  = site
      @glob  = site.resources.map(&:path).map { |p| File.join(p, '**/*.*') }
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
    
    def files
      @files = Dir[*@glob].map { |file| File.mtime(file) }
    end
  end
end
