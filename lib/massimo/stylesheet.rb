module Massimo
  class Stylesheet < Massimo::Resource
    def extension
      if Tilt.registered?(super[1..-1])
        '.css'
      else
        super
      end
    end
  end
end