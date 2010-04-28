**Massimo** sites are built using the command line. Run `massimo help` or `massimo help [command]` for more detailed usage information. All commands can be abbreviated, for example `generate` can be called with `g`, and `watch` with `w`.

Generate
--------

The first step after installation is to generate a new project. This can be done with the `generate` command:

    massimo generate my-site-name
    
This will create a folder with the basic structure of a massimo project.

You can also generate resources using the generate command. This will create a new file in the pages directory named `about-us.erb`.

    massimo generate page about-us.erb
    
    
Build
-----
    
After you've generated a **massimo** project and created some pages, you can build your site by runninging the `build` command. This will build the site into the public directory by default. *The build command is the default command.*

    cd my-site-name
    massimo build
    # or just:
    massimo
    
    
Watch
-----

Running that command over and over again would been a pain the arse, so **massimo** can just watch for changes automatically build your site when needed:

    massimo watch
    

Server
------

Like the other static website generators, **massimo** comes with a server. Unlike the others, it's a [Rack](http://rack.rubyforge.org/) application. When a request is made, the server will check for file changes and rebuild the site if necessary. To launch the server from the command line, to use the `server` command:

    massimo server
    # defaults to port 3000
    massimo server 5000
    # uses port 5000
    