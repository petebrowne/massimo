module Massimo
  module Resource
    module Collection
      # Find all the the Resources in this Resource type's directory.
      def all(reload = false)
        return @resources if defined?(@resources) && !reload
        @resources = find_resource_files.collect { |file| self.new(file) }
      end
    
      protected
      
        # Returns only the files listed in the options or all the files in this
        # Resource type's directory, with certain files filtered out.
        def find_resource_files
          files = site.options[name] && site.options[name].dup
          unless files and files.is_a?(::Array)
            files = ::Dir.glob(::File.join(dir, "**", "*")) unless files && files.is_a?(::Array)
            reject_partials_and_directories!(files)
            reject_skipped_files!(files)
          end
          files
        end
        
        # Reject all files that begin with "_" (like partials) and directories
        def reject_partials_and_directories!(files)
          files.reject! { |file| ::File.basename(file) =~ /^_/ || ::File.directory?(file) }
        end
        
        # Reject the files in the skip_files option, which can either be an Array of files to skip
        # or a Proc that returns true if the file should be skipped.
        def reject_skipped_files!(files)
          if skip_files = site.options["skip_#{name}".to_sym]
            files.reject! do |file|
              file.sub!("#{dir}/", "")
              case skip_files
              when ::Array
                skip_files.include?(file)
              when ::Proc
                skip_files.call(file)
              else
                false
              end
            end
          end
        end
    end
  end
end
