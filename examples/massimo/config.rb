require 'haml'
require 'sass'
require 'rdiscount'

config.base_url = '/massimo'

helpers do
  def nav_link_to(title, url, current_page)
    link_to(title, url, :class => (url == current_page.url) ? 'active' : nil)
  end
end
