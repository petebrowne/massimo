A **massimo** project looks something like this, though each directory's path can be customized.

    my-site/
      config.rb
      helpers/
      javascripts/
        main.js
      lib/
      pages/
        index.haml
      public/
      stylesheets/
        main.sass
      views/
         layouts/
           main.haml
           
<table>
  <tbody>
    <tr>
      <th>config.rb</th>
      <td>The project's <a href="/massimo/config/">config file</a></td>
    </tr>
    <tr>
      <th>helpers</th>
      <td>This is where you put helper modules (like Rails). This modules will automatically be available in your pages and views.</td>
    </tr>
    <tr>
      <th>javascripts</th>
      <td>This is where you put the working copies of your javascripts. They will be concatenated, minified, and moved to your output directory when the site is processed.</td>
    </tr>
    <tr>
      <th>lib</th>
      <td>This is where you put additional libraries. This is where you would add additional Tilt Templates.</td>
    </tr>
    <tr>
      <th>pages</th>
      <td>These are the actual pages (content) of your site. Anything here that is registered by a Tilt Template will be transformed into HTML and moved to the appropriate place in the output directory.</td>
    </tr>
    <tr>
      <th>public</th>
      <td>By default, this is where your site will be built.</td>
    </tr>
    <tr>
      <th>stylesheets</th>
      <td>This is where you put the working copies of your stylesheets. If they are Sass or Less documents, they will be transformed into CSS documents then moved to your output directory.</td>
    </tr>
    <tr>
      <th>views</th>
      <td>This is where you put partials and layouts (like Rails). You can render partials from your pages by calling <code>render('partial_name')</code>.</td>
    </tr>
  </tbody>
</table>
