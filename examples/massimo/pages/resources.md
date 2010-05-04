Resources are the content that gets transformed or copied when building your site. Pages, javascripts, and stylesheets are all types of resources.

Custom Resources
----------------

You can even make your own custom resource by using the `resource` method:

    # config.rb
    resource :post
    
**Massimo** will look in the posts directory for any files and transform them much like Pages. By default The posts will be available at the /posts url. For instance:

    post = Post.new('posts/first-port.md')
    post.url # '/posts/first-post/'
    
The location of the posts directory and the posts url can be customized:

    # config.rb
    config.posts_path = 'blog'
    config.posts_url  = '/blog'
    
    resource :post
    
Now all the posts will be located in the blog directory and and the urls will be prefixed with '/blog'.

    post = Post.new('blog/first-port.md')
    post.url # '/blog/first-post/'
    
What if you wanted to include the published date in the url? Simple, just add a url method in the resource:

    # config.rb
    resource :post do
      def url
        "/blog/#{published_at.strftime('%Y/%m/%d')}/#{title.downcase.gsub(/\s+/, '-')}"
      end
    end

Now, given the following Post:

    # posts/first-post.md
    ---
    title: My First Post
    published_at: 2010-04-28
    ---
    etc...
    
It will have the following url:

    post = Post.new('posts/first-port.md')
    post.url # '/blog/2010/04/08/my-first-post/'
    
    
Resources are like Models
-------------------------

You can use Resources in a very similar way to how you would use a model in Rails. Let's say you have a list of users to display on a page, but they don't need individual pages.

    # config.rb
    resource :user do
      unprocessable
    end

The `unprocessable` macro tells **massimo** to not process the user resources. Now you can have a bunch of user files:

    # users/bob.yml
    name: Bob
    
    # users/sue.yml
    name: Sue
    
    # users/jack.yml
    name: Jack
    
*Note: If a resource is a YAML file, the entire file's content will be treated as YAML. The front matter black is not necessary.*
    
And on the page you need to list the Users, you could get an array of the resources by calling `User.all`:

    # pages/index.haml
    - User.all.each do |user|
      %p= user.name
      