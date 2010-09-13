require 'spec_helper'

describe Massimo::Javascript do
  context 'with normal .js files' do
    let(:javascript) { Massimo::Javascript.new 'javascripts/main.js' }
    
    it 'should copy content' do
      with_file 'javascripts/main.js', 'var number = 42;' do
        javascript.render.should == "var number = 42;\n"
      end
    end
    
    it 'should concat using Sprockets' do
      within_construct do |c|
        c.file 'javascripts/main.js', '//= require "_plugin.js"'
        c.file 'javascripts/_plugin.js', 'var number = 42;'
        javascript.render.should == "var number = 42;\n"
      end
    end
  end
  
  context 'with .coffee scripts' do
    let(:javascript) { Massimo::Javascript.new 'javascripts/main.coffee' }
    
    it 'should render using CoffeeScript' do
      with_file 'javascripts/main.coffee', 'number: 42' do
        javascript.render.should == "(function(){\n  var number;\n  number = 42;\n})();"
      end
    end
    
    it 'should output .js files' do
      with_file 'javascripts/main.coffee' do
        javascript.output_path.extname.should == '.js'
      end
    end
  end
  
  context 'with compression' do
    let(:javascript) { Massimo::Javascript.new 'javascripts/main.js' }
    
    context 'using :min' do
      it 'should compress using JSMin' do
        Massimo.config.javascripts_compressor = :min
        with_file 'javascripts/main.js', 'function(number) { return number + 2; }' do
          javascript.render.should == 'function(number){return number+2;}'
        end
      end
    end
    
    context 'using :pack' do
      it 'should compress using Packr' do
        Massimo.config.javascripts_compressor = :pack
        with_file 'javascripts/main.js', 'function(number) { return number + 2; }' do
          javascript.render.should == 'function(a){return a+2}'
        end
      end
      
      it 'should be configurable' do
        Massimo.config.javascripts_compressor = :pack
        Massimo.config.packr = { :shrink_vars => false }
        with_file 'javascripts/main.js', 'function(number) { return number + 2; }' do
          javascript.render.should == 'function(number){return number+2}'
        end
      end
    end
  end
end
