Metadata can be added to Pages and [custom Resources](/massimo/resources) by using YAML. The YAML front matter must be the first thing in the file and takes the form of:

    ---
    title: Using YAML Front Matter
    layout: false
    ---
    
    
Predefined Metadata
-------------------

<table>
  <tbody>
    <tr>
      <th>title</th>
      <td>This is the title of the Page. By default it will be generated from the basename of the Page file. For Example: <code>my-first-post.haml</code> would become <code>'My First Post'</code>.</td>
    </tr>
    <tr>
      <th>extension</th>
      <td>This would be the extension of the file generated from the Page file. This defaults to <code>'.html'</code>.</td>
    </tr>
    <tr>
      <th>url</th>
      <td>This is the URL that will be used to determine the output file's location and name. This defaults to the same location (relative to the pages directory) of the Page and its filename without the extension (and dasherized). For Example: The Page: <code>pages/about_us/our_services.haml</code> would default to the URL: <code>'/about-us/our-services/'</code>.</td>
    </tr>
    <tr>
      <th>layout</th>
      <td>This is the name of the layout used for the Page. Settings this value to false will process the Page without a layout. This defaults to <code>'main'</code>.</td>
    </tr>
  </tbody>
</table>


Custom Metadata
----------------

Any other metadata will be available as locals in your pages. For instance:

    ---
    title: It's Christmas!
    date: 2009-12-25
    ---
    <h1><%= title %></h1>
    <p><%= date.strftime("%m, %e, %Y") %></p>

The page object will also be available in your layout as page, and the same methods can be called on it:

    <html>
      <head>
        <title><%= page.title %></title>
      </head>
      <body>
        <%= yield %>
      </body>
    </html>
