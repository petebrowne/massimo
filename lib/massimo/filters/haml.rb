# Add the Haml filter
Massimo::Filters.register(:haml) do |data, locals|
  require "haml" unless defined? ::Haml
  ::Haml::Engine.new(data).render(Object.new, locals)
end
