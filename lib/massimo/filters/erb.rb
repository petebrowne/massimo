# Add the filter for ERB files.
Massimo::Filters.register(:erb) do |data, template, locals|
  require "erb" unless defined? ::ERB
  binding = template.local_binding(locals)
  ::ERB.new(data).result(binding)
end