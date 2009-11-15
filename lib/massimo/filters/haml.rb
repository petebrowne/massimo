# Add the Haml filter
Massimo::Filters.register(:haml) do |data, template, locals|
  require "haml" unless defined? ::Haml
  ::Haml::Engine.new(data).render(template, locals)
end
