module Massimo
  class Javascript < Massimo::Resource
    def render
      case source_path.extname.to_s
      when '.coffee'
        CoffeeScript.compile(content)
      else
        super
      end
    end
    def extension
      @extension ||= '.js'
    end
  end
end
