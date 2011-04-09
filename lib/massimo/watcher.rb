module Massimo
  class Watcher
    class << self
      def start(site)
        Massimo::UI.say 'massimo is watching your files for changes', :growl => true
        self.new(site).run
      end
    end
    
    def initialize(site)
      @site           = site
      @previous_files = []
      check_config
    end
    
    # Runs a loop, processing the Site whenever files have changed.
    def run
      begin
        loop do
          Massimo::UI.report_errors { process }
          sleep 0.5
        end
      rescue Interrupt
        exit
      end
    end
    
    # Processes the Site if any of the files have changed.
    def process
      if config_changed?
        Massimo::UI.say 'massimo is reloading your site'
        @site.reload
        @site.process
        Massimo::UI.say 'massimo has built your site', :growl => true
      elsif changed?
        Massimo::UI.say 'massimo has noticed a change'
        @site.process
        Massimo::UI.say 'massimo has built your site', :growl => true
      end
    end
    
    # Determine if any of the Site's files have changed.
    def changed?
      @previous_files != check_files
    end
    
    # Determine if the Site's config file has chanaged.
    def config_changed?
      @previous_config != check_config
    end
    
    protected
    
      def check_config
        @previous_config = File.exist?(@site.config.config_path) && File.mtime(@site.config.config_path)
      end
    
      def check_files
        @previous_files = Dir[*glob].map { |file| File.mtime(file) }
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