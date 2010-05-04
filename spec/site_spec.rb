require File.expand_path('../spec_helper', __FILE__)

describe Massimo::Site do
  describe '#initialize' do
    context 'with an options hash' do
      it 'configures the site' do
        site = Massimo::Site.new :source_path => 'source/dir'
        site.config.source_path.should == File.expand_path('source/dir')
      end
    end
    context 'with a string' do
      it 'should read a YAML file for configuration' do
        with_file 'config.yml', "source_path: source/dir\n" do
          site = Massimo::Site.new 'config.yml'
          site.config.source_path.should == File.expand_path('source/dir')
        end
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
  end
  
  describe '#resources' do
    it 'should be an array' do
      Massimo::Site.new.resources.should be_an_instance_of(Array)
    end
    
    it 'should include Massimo::Page by default' do
      Massimo::Site.new.resources.should include(Massimo::Page)
    end
    
    it 'should include Massimo::Javascript by default' do
      Massimo::Site.new.resources.should include(Massimo::Javascript)
    end
    
    it 'should include Massimo::Stylesheet by default' do
      Massimo::Site.new.resources.should include(Massimo::Stylesheet)
    end
    
    it 'should include Massimo::View by default' do
      Massimo::Site.new.resources.should include(Massimo::View)
    end
  end
  
  describe '#resource' do
    context 'with a Class constant' do
      it "should add a resource to the site's resources" do
        Post = Class.new(Massimo::Resource)
        site = Massimo::Site.new
        site.resource Post
        site.resources.should include(Post)
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
      
      it 'should create a class that inherits from Page' do
        Comment.superclass.should == Massimo::Page
      end
      
      it "should add the class to the site's resources" do
        @site.resources.should include(Comment)
      end
      
      it 'should add the methods in the class body' do
        with_file 'comment.txt' do
          Comment.new('comment.txt').should be_spam
        end
      end
    end
  end
  
  describe '#template_scope' do
    it 'should return an object with the Helpers methods included' do
      Massimo.site.template_scope.methods.should include('render')
    end
  end
  
  describe '#helpers' do
    context 'with a block' do
      it 'should add the defined methods to the template scope' do
        Massimo.site.helpers do
          def hello
            'world'
          end
        end
        Massimo.site.template_scope.hello.should == 'world'
      end
    end
    
    context 'with a Module' do
      it 'should extend the template_scope with the given Module' do
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
    
    it 'should process each resource' do
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
    
    it 'should not process views' do
      with_file 'views/partial.haml' do
        Massimo.site.process
        processed_files.should be_empty
      end
    end
    
    context 'with a custom resource' do
      it 'should process the resource' do
        with_file 'videos/keyboard-cat.html' do
          Massimo.site.resource :video
          Massimo.site.process
          processed_files.should =~ %w( public/keyboard-cat/index.html )
        end
      end
    end
    
    context 'with lib files' do
      it 'should load them' do
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
      
      it 'should reload them' do
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
      
      it 'should remove previously loaded libs' do
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
      it 'should extend the template scope' do
        content = <<-CONTENT.unindent
          module SomeHelper
            def test
              'working'
            end
          end
        CONTENT
        with_file 'helpers/some_helper.rb', content do
          Massimo.site.process
          Massimo.site.template_scope.test.should == 'working'
        end
      end
      
      it 'should reload the methods in the template scope' do
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
