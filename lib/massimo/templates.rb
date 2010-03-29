module Tilt
  register :html, Tilt::ERBTemplate
  register :php,  Tilt::ERBTemplate
  
  # My Markdown implementation.
  class MarkdownTemplate < Template
    def prepare
      @erb_engine = Tilt::ERBTemplate.new { data }
    end

    def evaluate(scope, locals, &block)
      # First evaluate the code using ERB
      erb_output = @erb_engine.render(scope, locals, &block)
      # Then evaluate the code using the RDiscountTemplate
      Tilt::RDiscountTemplate.new { erb_output }.render
    end
  end
  register :markdown, MarkdownTemplate
  register :md, MarkdownTemplate
end
