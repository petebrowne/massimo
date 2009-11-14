# Add filter for markdown
Massimo::Filters.register([ :markdown, :md ]) do |data, locals|
  require "rdiscount" unless defined?(::RDiscount)
  erb_output = Massimo.filter(data, :erb, locals)
  RDiscount.new(erb_output).to_html
end
