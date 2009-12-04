# Add the filter for ERB files.
Massimo::Filters.register([ :erb, :html, :php ]) do |data, template, locals|
  require "erb" unless defined? ::ERB
  binding = template.local_binding(locals)
  ::ERB.new(data).result(binding)
end