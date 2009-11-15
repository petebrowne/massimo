# Add filter for markdown
Massimo::Filters.register([ :markdown, :md ]) do |data, template, locals|
  require "rdiscount" unless defined?(::RDiscount)
  erb_output = Massimo.filter(data, :erb, template, locals)
  RDiscount.new(erb_output).to_html
end
