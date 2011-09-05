require 'spec_helper'

describe Massimo::CLI do
  def massimo(args)
    Massimo::CLI.start(args.split(' '))
  end
  
  describe '#site' do
    before :each do
      stub(Massimo::Watcher).start { is_a(Massimo::Site) }
    end
    
    context "with '--environment staging'" do
      it 'sets the environment option' do
        massimo 'watch --environment staging'
        Massimo.config.environment.should == 'staging'
      end
    end
    
    context "with '--production'" do
      it 'sets the environment option' do
        massimo 'watch --production'
        Massimo.config.environment.should == 'production'
      end
    end
    
    context "with '--config_path my_site.rb'" do
      it 'sets the config_path option' do
        massimo 'watch --config_path my_site.rb'
        Massimo.config.config_path.should == File.expand_path('my_site.rb')
      end
    end
    
    context "with '--source_path source'" do
      it 'sets the source_path option' do
        massimo 'watch --source_path source'
        Massimo.config.source_path.should == File.expand_path('source')
      end
    end
    
    context "with '--output_path output'" do
      it 'sets the output_path option' do
        massimo 'watch --output_path output'
        Massimo.config.output_path.should == File.expand_path('output')
      end
    end
  end
  
  describe '#build' do
    it 'builds the site' do
      silence(:stdout) do
        mock(Kernel).exit(true)
        mock.instance_of(Massimo::CLI).site { mock!(:process) }
        massimo 'build'
      end
    end
    
    context 'with errors' do
      it "exits with status code of 1" do
        silence(:stdout) do
          mock(Kernel).exit(false)
          mock.instance_of(Massimo::CLI).site do
            mock!(:process) { raise 'Error!' }
          end
          massimo 'build'
        end
      end
    end
    
    context "with mapping 'b'" do
      it 'builds the site' do
        silence(:stdout) do
          mock(Kernel).exit(true)
          mock.instance_of(Massimo::CLI).site { mock!(:process) }
          massimo 'b'
        end
      end
    end
  end
  
  describe '#new' do
    it 'creates a massimo site directory' do
      within_construct do |c|
        massimo 'new my_site'
        'my_site'.should be_a_directory
      end
    end
    
    it 'creates resource directories' do
      within_construct do |c|
        massimo 'new my_site'
        'my_site/pages'.should be_a_directory
        'my_site/views'.should be_a_directory
        'my_site/javascripts'.should be_a_directory
        'my_site/stylesheets'.should be_a_directory
      end
    end
    
    it 'creates an output path' do
      within_construct do |c|
        massimo 'new my_site'
        'my_site/public'.should be_a_directory
      end
    end
    
    it 'creates an default index page' do
      within_construct do |c|
        massimo 'new my_site'
        content = <<-EOS.unindent
          ---
          title: Home Page
          ---
          <h1><%= title %></h1>
          <p>Find me in pages/index.erb</p>
        EOS
        'my_site/pages/index.html.erb'.should be_a_file.with_content(content)
      end
    end
    
    it 'creates a default layout' do
      within_construct do |c|
        massimo 'new my_site'
        content = <<-EOS.unindent
        <!doctype html>
        <html>
          <head lang="en">
            <meta charset="utf-8">
            <title><%= page.title %></title>
            <%= stylesheet_link_tag "main" %>
            <%= javascript_include_tag "main" %>
          </head>
          <body>
            <%= yield %>
          </body>
        </html>
        EOS
        'my_site/views/layouts/main.html.erb'.should be_a_file.with_content(content)
      end
    end
    
    it 'creates a default javascript file' do
      within_construct do |c|
        massimo 'new my_site'
        'my_site/javascripts/main.js'.should be_a_file
      end
    end
    
    it 'creates a default stylesheet file' do
      within_construct do |c|
        massimo 'new my_site'
        'my_site/stylesheets/main.css.scss'.should be_a_file
      end
    end
    
    it 'creates a default Gemfile' do
      within_construct do |c|
        massimo 'new my_site'
        content = <<-EOS.unindent
          source :rubygems
          
          gem "massimo", "#{Massimo::VERSION}"
          gem "sass", "~> 3.1"
          
          group :production do
            gem "uglifier", "~> 1.0"
          end
        EOS
        'my_site/Gemfile'.should be_a_file.with_content(content)
      end
    end
    
    it 'creates a default config file' do
      within_construct do |c|
        massimo 'new my_site'
        content = <<-EOS.unindent
          require "bundler"
          Bundler.require :default, config.environment.to_sym
          
          # This is an example configuration File
          # Look here for all the available options:
          # http://massimo.petebrowne.com/configuration/
          
          if config.environment.production?
            # Compress javascripts and stylesheets
            config.compress = true
          end
          
          helpers do
            # Define helper methods here
          end
        EOS
        'my_site/config.rb'.should be_a_file.with_content(content)
      end
    end
    
    it 'creates a default rackup file' do
      within_construct do |c|
        massimo 'new my_site'
        content = <<-EOS.unindent
          require "massimo"
          run Massimo::Server.new
        EOS
        'my_site/config.ru'.should be_a_file.with_content(content)
      end
    end
    
    context "with mapping 'g'" do
      it 'creates a massimo site directory' do
        within_construct do |c|
          silence(:stdout) do
            massimo 'n my_site'
            'my_site'.should be_a_directory
          end
        end
      end
    end
  end
  
  describe '#server' do
    it 'starts a server at port 3000' do
      silence(:stdout) do
        mock(Massimo::Server).start is_a(Massimo::Site), 3000
        massimo 'server'
      end
    end
    
    context 'with a given port number' do
      it 'starts a server at the given port' do
        silence(:stdout) do
          mock(Massimo::Server).start is_a(Massimo::Site), 1234
          massimo 'server 1234'
        end
      end
    end
    
    context "with mapping 's'" do
      it 'starts a server at port 3000' do
        silence(:stdout) do
          mock(Massimo::Server).start is_a(Massimo::Site), 3000
          massimo 's'
        end
      end
    end
  end
  
  describe '#watch' do
    it 'watches the files for changes' do
      silence(:stdout) do
        mock(Massimo::Watcher).start is_a(Massimo::Site)
        massimo 'watch'
      end
    end
    
    context "with mapping 'w'" do
      it 'watches the files for changes' do
        silence(:stdout) do
          mock(Massimo::Watcher).start is_a(Massimo::Site)
          massimo 'w'
        end
      end
    end
  end
  
  describe '#version' do
    it 'prints out the current version number' do
      output = capture(:stdout) { Massimo::CLI.start(%w(version)) }
      output.strip.should == Massimo::VERSION
    end
    
    %w(v -v --version).each do |mapping|
      context "with mapping '#{mapping}'" do
        it 'prints out the current version number' do
          output = capture(:stdout) { Massimo::CLI.start(%W(#{mapping})) }
          output.strip.should == Massimo::VERSION
        end
      end
    end
  end
end
