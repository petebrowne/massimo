# Add the filter for ERB files.
Massimo::Filters.register(:erb) do |data, locals|
  require "erb" unless defined? ::ERB
  # Taken from Sinatra, for getting locals into ERB
  locals_assigns = locals.to_a.collect { |k, v| "#{k} = locals[:#{k}]" }
  render_binding = binding
  eval locals_assigns.join("\n"), render_binding
  
  ::ERB.new(data).result(render_binding)
end