# Add filter for evaling Ruby Code
Massimo::Filters.register([ :ruby, :rb ]) do |data, template, locals|
  binding = template.local_binding(locals)
  eval(data, binding).to_s
end
