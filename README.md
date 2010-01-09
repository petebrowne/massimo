# Massimo

Massimo is a full static website generator. While making [Rails](http://rubyonrails.org/) websites I became dependent on [Haml](http://haml-lang.com/), [Sass](http://sass-lang.com/), and other useful gems. I wanted to use that workflow to rapidly make simple, static websites. Massimo's code is inspired by other website generators like [Jekyll](http://github.com/mojombo/jekyll) and [Webby](http://webby.rubyforge.org/). It's features include:

* It renders templates and views using [Tilt](http://github.com/rtomayko/tilt)
* It uses familiar helper methods from [Sinatra::More](http://github.com/nesquena/sinatra_more)
* It supports custom helper methods like [Rails](http://rubyonrails.org/) and [Sinatra](http://www.sinatrarb.com/)
* It concats javascripts using [Sprockets](http://getsprockets.org/)
  and then minifies them using [JSMin](http://github.com/rgrove/jsmin)
* It renders stylesheets using either [Sass](http://sass-lang.com/) or [Less](http://lesscss.org/)


## Installation

Massimo is hosted on [Gemcutter](http://gemcutter.org/) at http://gemcutter.org/gems/massimo, so installation is simply:

    sudo gem install massimo
 
 
## Basic Usage

1. Setup the structure of the Site
2. Create some pages
3. Run you Site locally to see how it looks
4. Deploy your Site


## Structure

A basic Massimo Site looks something like this, though each directory's path can be customized:

    .
    |-- config.yml
    |
    |-- helpers
    |   `-- my_helpers.rb
    |
    |-- javascripts
    |   |-- _plugin.js
    |   `-- application.js
    |
    |-- lib
    |   `-- post.rb
    |
    |-- pages
    |   |-- index.haml
    |   |-- contact.haml
    |   `-- about-us.haml
    |
    |-- stylesheets
    |   |-- _base.sass
    |   `-- application.sass
    |
    |-- views
    |   |-- partial.haml
    |   `-- layouts
    |       `-- applcation.haml
    |
    `-- public
  
#### config.yml

This where you setup the options for the Site.

#### helpers

This is where you put helper modules (like Rails). This modules will automatically be available in your pages and views.

#### javascripts

This is where you put the working copies of your javascripts. They will be concatenated, minified, and moved to your output directory when the site is processed.

#### lib

This is where you put additional libraries. You can customize the default Massimo classes or add your own here. This is where you would add additional Tilt Templates.

#### pages

These are the actual pages (content) of your site. Anything here that is registered by a Tilt Template will be transformed into HTML and moved to the appropriate place in the output directory.

#### stylesheets

This is where you put the working copies of your stylesheets. If they are Sass or Less documents, they will be transformed into CSS documents then moved to your output directory.

#### views

This is where you put partials and layouts (like Rails). You can render partials from your pages by calling `render("partial_name")`.


## Running Massimo

### Using the Command Line
  
Usually this is done through the massimo executable, which is installed with the gem. In order to get a server up and running with your Massimo site, run `massimo --server` and then browse to http://localhost:1984/. Or you could simply run `massimo --watch` to watch for changes and regenerate the site. For full command line options run `massimo --help`.

### Using the Ruby lib

Massimo is designed to also work well with straight Ruby code. In order to create and process the Site you would do the following:

    require "rubygems"
    require "massimo"
    
    site = Massimo::Site(:source => "./source", :output => "./output") # Create a site with the given configuration options
    site.pages # An array of all the pages found in the pages directory
    site.process! # Processes all the source files and generates the output files.


## YAML Front Matter

Pages can contain YAML front matter blocks for either predefined configuration options or custom variables. The front matter must be the first thing in the file and takes the form of:

    ---
    title: Using YAML Front Matter
    layout: false
    ---

### Options
    
The options available are:

#### title

This is the title of the Page. By default it will be generated from the basename of the Page file. For Example: `my-first-post.haml` would become `"My First Post"`.

#### extension

This would be the extension of the file generated from the Page file. This defaults to `".html"`.

#### url

This is the URL that will be used to determine the output file's location and name. This defaults to the same location (relative to the pages directory) of the Page and its filename without the extension (and dasherized). For Example: The Page: `posts/10_best_rubygems.haml` would default to the URL: `"posts/10-best-rubygems/"`.

#### layout

This is the name of the layout used for the Page. Settings this value to `false` will process the Page without a layout. This defaults to `"application"`.

### Custom Variables
    
Any other variables will be available as methods in your pages. For instance:

    ---
    title: It's Christmas!
    date: 2009-12-25
    ---
    <h1><%= title %></h1>
    <p><%= date.strftime("%m, %e, %Y") %></p>
    
The page object will also be available in your layout as `page`, and the same methods can be called on it:

    <html>
      <head>
        <title><%= page.title %></title>
      </head>
      <body>
        <%= yield %>
      </body>
    </html>


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

Copyright (c) 2009 [Peter Browne](http://petebrowne.com). See LICENSE for details.
