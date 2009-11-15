# Add filter for textile
Massimo::Filters.register(:textile) do |data, template, locals|
  require "RedCloth" unless defined?(::RedCloth)
  erb_output = Massimo.filter(data, :erb, template, locals)
  RedCloth.new(erb_output).to_html
end
