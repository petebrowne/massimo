require 'spec_helper'

describe Massimo::Site do
  describe '#initialize' do
    context 'with an options hash' do
      it 'configures the site' do
        site = Massimo::Site.new :source_path => 'source/dir'
        site.config.source_path.should == File.expand_path('source/dir')
      end
    end
    
    context 'with a block' do
      it 'configures the site' do
        site = Massimo::Site.new do
          config.source_path = 'source/dir'
        end
        site.config.source_path.should == File.expand_path('source/dir')
      end
    end
    
    context 'with a config file' do
      it 'evals the config file' do
        with_file 'config.rb', 'config.output_path = "output/dir"' do
          site = Massimo::Site.new
          site.config.output_path.should == File.expand_path('output/dir')
        end
      end
      
      context 'with a specified path' do
        it 'evals the config file' do
          with_file 'config/site.rb', 'config.output_path = "output/dir"' do
            site = Massimo::Site.new :config_path => 'config/site.rb'
            site.config.output_path.should == File.expand_path('output/dir')
          end
        end
      end
    end
  end
  
  describe 'reload' do
    it 'reloads the config file' do
      within_construct do |c|
        c.file 'config.rb', 'config.output_path = "output/dir"'
        site = Massimo::Site.new
        c.file 'config.rb', 'config.output_path = "output"'
        site.reload
        site.config.output_path.should == File.expand_path('output')
      end
    end
    
    it 'resets the resources array' do
      Post = Class.new(Massimo::Resource)
      site = Massimo::Site.new
      site.resource Post
      site.reload
      site.resources.should_not include(Post)
      Object.class_eval { remove_const :Post }
    end
    
    it 'uses original options' do
      within_construct do |c|
        c.file 'config.rb', 'config.output_path = "output/dir"'
        site = Massimo::Site.new :output_path => 'output'
        c.file 'config.rb', 'config.source_path = "source/dir"'
        site.reload
        site.config.output_path.should == File.expand_path('output')
        site.config.source_path.should == File.expand_path('source/dir')
      end
    end
  end
  
  describe '#resources' do
    it 'is an array of the default resources' do
      Massimo::Site.new.resources.should =~ [ Massimo::Page, Massimo::Javascript, Massimo::Stylesheet, Massimo::View ]
    end
  end
  
  describe '#resource' do
    context 'with a Class constant' do
      it "adds a resource to the site's resources" do
        Post = Class.new(Massimo::Resource)
        site = Massimo::Site.new
        site.resource Post
        site.resources.should include(Post)
        Object.class_eval { remove_const :Post }
      end
    end
    
    context 'with a Class body' do
      before do
        @site = Massimo::Site.new
        @site.resource :comment do
          def spam?
            true
          end
        end
      end
      
      after do
        Object.class_eval do
          remove_const :Comment
        end
      end
      
      it 'creates a class that inherits from Page' do
        Comment.superclass.should == Massimo::Page
      end
      
      it "adds the class to the site's resources" do
        @site.resources.should include(Comment)
      end
      
      it 'adds the methods in the class body' do
        with_file 'comment.txt' do
          Comment.new('comment.txt').should be_spam
        end
      end
    end
  end
  
  describe '#template_scope' do
    it 'returns an object with the Helpers methods included' do
      Massimo.site.template_scope.methods.map(&:to_s).should include('render')
    end
  end
  
  describe '#helpers' do
    context 'with a block' do
      it 'adds the defined methods to the template scope' do
        Massimo.site.helpers do
          def hello
            'world'
          end
        end
        Massimo.site.template_scope.hello.should == 'world'
      end
    end
    
    context 'with a Module' do
      it 'extends the template_scope with the given Module' do
        module CycleHelper
          def cycle
            'even'
          end
        end
        Massimo.site.helpers CycleHelper
        Massimo.site.template_scope.cycle.should == 'even'
      end
    end
  end
  
  describe '#process' do
    let(:processed_files) { Dir.glob('public/**/*.*') }
    
    it 'processes each resource' do
      within_construct do |c|
        c.file 'pages/index.html'
        c.file 'pages/about-us.html'
        c.file 'javascripts/main.js'
        c.file 'stylesheets/main.css'
        Massimo.site.process
        processed_files.should =~ [
          'public/index.html',
          'public/about-us/index.html',
          'public/javascripts/main.js',
          'public/stylesheets/main.css'
        ]
      end
    end
    
    it 'does not process views' do
      with_file 'views/partial.haml' do
        Massimo.site.process
        processed_files.should be_empty
      end
    end
    
    context 'with a custom resource' do
      it 'processes the resource' do
        with_file 'videos/keyboard-cat.html' do
          Massimo.site.resource :video
          Massimo.site.process
          processed_files.should =~ %w( public/keyboard-cat/index.html )
        end
      end
    end
    
    context 'with lib files' do
      it 'loads them' do
        content = <<-CONTENT.unindent
          class Massimo::Site
            def test
              true
            end
          end
        CONTENT
        with_file 'lib/site.rb', content do
          Massimo.site.process
          Massimo.site.test.should === true
        end
      end
      
      it 'reloads them' do
        content = <<-CONTENT.unindent
          class Massimo::Site
            def test
              false
            end
          end
        CONTENT
        with_file 'lib/site.rb', content do
          expect {
            Massimo.site.process
          }.to change(Massimo.site, :test).to(false)
        end
      end
      
      it 'removes previously loaded libs' do
        with_file 'lib/some_constant.rb', 'module SomeConstant; end' do
          Massimo.site.process
          File.delete 'lib/some_constant.rb'
          Massimo.site.process
          expect {
            SomeConstant
          }.to raise_error
        end
      end
    end
    
    context 'with helper files' do
      it 'extends the template scope' do
        content = <<-CONTENT.unindent
          module SomeHelper
            def helper_method
              'working'
            end
          end
        CONTENT
        with_file 'helpers/some_helper.rb', content do
          Massimo.site.process
          Massimo.site.template_scope.helper_method.should == 'working'
        end
      end
      
      it 'reloads the methods in the template scope' do
        content = <<-CONTENT.unindent
          module Helper
            def testing
              'working'
            end
          end
        CONTENT
        with_file 'helpers/helper.rb', content do
          Massimo.site.process
          File.delete 'helpers/helper.rb'
          Massimo.site.process
          expect {
            Massimo.site.template_scope.testing
          }.to raise_error
        end
      end
    end
  end
end