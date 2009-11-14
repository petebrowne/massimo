# Add filter for evaling Ruby Code
Massimo::Filters.register([ :ruby, :rb ]) do |data, locals|
  eval(data).to_s
end
