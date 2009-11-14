# Add filter for textile
Massimo::Filters.register(:textile) do |data, locals|
  require "RedCloth" unless defined?(::RedCloth)
  erb_output = Massimo.filter(data, :erb, locals)
  RedCloth.new(erb_output).to_html
end
