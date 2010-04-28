# Massimo

Massimo is a static website builder that allows you to use dynamic technologies such as Haml & Sass for rapid development.

*Massimo's code is inspired by other website generators like [Jekyll](http://github.com/mojombo/jekyll) and [Webby](http://webby.rubyforge.org/).*

## Features

* Renders templates and views using [Tilt](http://github.com/rtomayko/tilt)
* Uses familiar helper methods from [Sinatra::More](http://github.com/nesquena/sinatra_more)
* Supports custom helper methods like [Rails](http://rubyonrails.org/) and [Sinatra](http://www.sinatrarb.com/)
* Concats javascripts using [Sprockets](http://getsprockets.org/)
  and then minifies them using [JSMin](http://github.com/rgrove/jsmin)
* Renders stylesheets using either [Sass](http://sass-lang.com/) or [Less](http://lesscss.org/)
* Automatically creates pretty URLs

## Getting Started
    
    gem install massimo
    massimo generate my-site
    cd my-site
    massimo build

## Copyright

Copyright (c) 2009 [Peter Browne](http://petebrowne.com). See LICENSE for details.
