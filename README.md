# Massimo

Massimo is a full static website generator. While making [Rails](http://rubyonrails.org/) websites I became dependent on [Haml](http://haml-lang.com/), [Sass](http://sass-lang.com/), and other useful gems. I wanted to use that workflow to rapidly make simple, static websites. Massimo's code is inspired by other website generators like [Jekyll](http://github.com/mojombo/jekyll) and [Webby](http://webby.rubyforge.org/). It's features include:

* It renders templates and views using [Tilt](http://github.com/rtomayko/tilt)
* It uses familiar helper methods from [Sinatra::More](http://github.com/nesquena/sinatra_more)
* It supports custom helper methods like [Rails](http://rubyonrails.org/) and [Sinatra](http://www.sinatrarb.com/)
* It concats javascripts using [Sprockets](http://getsprockets.org/)
  and then minifies them using [JSMin](http://github.com/rgrove/jsmin)
* It renders stylesheets using either [Sass](http://sass-lang.com/) or [Less](http://lesscss.org/)
 
 
## Basic Usage

1. Setup the structure of the Site
2. Create some pages
3. Run you Site locally to see how it looks
4. Deploy your Site

### Structure

A basic Massimo Site looks something like this, though each directory's path can be customized:

    .
    |-- source
    |   |
    |   |-- config.yml
    |   |
    |   |-- helpers
    |   |   `-- my_helpers.rb
    |   |
    |   |-- javascripts
    |   |   |-- _plugin.js
    |   |   `-- application.js
    |   |
    |   |-- pages
    |   |   |-- index.haml
    |   |   |-- contact.haml
    |   |   `-- about-us.haml
    |   |
    |   |-- stylesheets
    |   |   |-- _base.sass
    |   |   `-- application.sass
    |   |
    |   `-- views
    |       |-- partial.haml
    |       `-- layouts
    |           `-- applcation.haml
    |
    `-- output
  
#### config.yml

This where you setup the options for the Site. It must be in the root of the source directory.

#### helpers

This is where you put helper modules (like Rails). This modules will automatically be available in your pages and views.

#### javascripts

This is where you put the working copies of your javascripts. They will be concatenated, minified, and moved to your output directory when the site is processed.

#### pages

These are the actual pages (content) of your site. Anything here will be transformed into HTML and moved to the appropriate place in the output directory.

#### stylesheets

This is where you put the working copies of your stylesheets. If they are Sass or Less documents, they will be transformed into CSS documents then moved to your output directory.

#### views

This is where you put partials and layouts (like Rails). You can render partials from your pages by calling `render("partial_name")`.

### Running Massimo
  
Usually this is done through the massimo executable, which is installed with the gem. In order to get a server up and running with your Massimo site, run `massimo --server` and then browse to http://localhost:1984/. Or you could simply run `massimo --watch` to watch for changes and regenerate the site.


## YAML Front Matter

Pages can contain YAML front matter blocks for either predefined configuration options or custom variables. The front matter must be the first thing in the file and takes the form of:

    ---
    title: Using YAML Front Matter
    layout: false
    ---

## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with Rakefile, VERSION, or history.
  (if you want to have your own version, that is fine but
  bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2009 [Peter Browne](http://peterbrowne.net). See LICENSE for details.
