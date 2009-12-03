module Massimo
  class Javascript < Resource
    # Concat the Javascript using Sprockets, then minify using JSmin
    def render
      secretary = Sprockets::Secretary.new(
        :assert_root  => self.site.output_dir,
        :source_files => [ @source_path.to_s ]
      )
      # install assets if necessary
      secretary.install_assets
      # minify the concatenated javascript
      JSMin.minify(secretary.concatenation.to_s)
    end
    
    # Writes the rendered js to the output file.
    def process!
      # Make the full path to the directory of the output file
      FileUtils.mkdir_p(self.output_path.dirname)
      # write the filtered data to the output file
      self.output_path.open("w") do |file|
        file.write self.render
      end
    end
    
    protected
      
      # Determine the output file path
      def output_path
        @output_path ||= Pathname.new(@source_path.to_s.
          sub(self.site.source_dir, self.site.output_dir)) # move to output dir
      end
  end
end
