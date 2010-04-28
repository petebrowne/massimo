**Massimo** projects can be configured through config files located in the root of your project. These config files will automatically detected when you run massimo [commands](/massimo/usage).


config.rb
---------

The prefered way is to use a `config.rb` file. In that file, you have access to all of the Site's methods. For example:

    config.javascripts_url = '/js'
    config.stylesheets_url = '/css'
    config.output_path     = '_site'
    
    resource :user do
      unprocessable
    end
    
    helpers do
      def users
        User.all
      end
    end
    
This config file does a few things:

* It changes the URLs for the javascripts and stylesheets.
* It changes the output path to `'_site'`
* It creates a custom [resource](/massimo/resources/).
* It creates a custom helper method to access the custom resources.


config.yml
----------

If all you need to do is set a couple of options, a `config.yml` file might be easier for you:

    javascripts_url: /js
    stylesheets_url: /css
    
    
Options
-------

<table>
  <tbody>
    <tr>
      <th>source_path</th>
      <td>The path to the source files of the project. Defaults to <code>'.'</code>.</td>
    </tr>
    <tr>
      <th>output_path</th>
      <td>The path to output the site to. Defaults to <code>'public'</code>.</td>
    </tr>
    <tr>
      <th>base_url</th>
      <td>The base url of this site. You would change this if the site existed in a subdirectory. Defaults to <code>'/'</code>.</td>
    </tr>
    <tr>
      <th>[resource]_path</th>
      <td>The path to where the given resources files are located. Defaults to the name of the resource. For example, <code>pages_path</code> defaults to <code>'pages'</code>, and <code>javascripts_path</code> defaults to <code>'javascripts'</code>.</td>
    </tr>
    <tr>
      <th>[resource]_url</th>
      <td>The base url for the given resources. Defaults to <code>'/javascripts'</code> for javascripts and <code>'/stylesheets'</code> for stylesheets. Defaults to <code>'/'</code> for everything else.</td>
    </tr>
  </tbody>
</table>