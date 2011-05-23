module Massimo
  class Stylesheet < Massimo::Resource
    def extension
      @extension ||= '.css'
    end
  end
end