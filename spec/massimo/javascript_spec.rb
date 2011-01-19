require 'spec_helper'

describe Massimo::Javascript do
  context 'with normal .js files' do
    let(:javascript) { Massimo::Javascript.new 'javascripts/main.js' }
    
    it 'copies content' do
      with_file 'javascripts/main.js', 'var number = 42;' do
        javascript.render.should == "var number = 42;\n"
      end
    end
    
    it 'concats using Sprockets' do
      within_construct do |c|
        c.file 'javascripts/main.js', '//= require "_plugin.js"'
        c.file 'javascripts/_plugin.js', 'var number = 42;'
        javascript.render.should == "var number = 42;\n"
      end
    end
  end
  
  context 'with .coffee scripts' do
    let(:javascript) { Massimo::Javascript.new 'javascripts/main.coffee' }
    
    it 'renders using CoffeeScript' do
      with_file 'javascripts/main.coffee', 'number: 42' do
        javascript.render.should == "(function(){\n  var number;\n  number = 42;\n})();"
      end
    end
    
    it 'outputs .js files' do
      with_file 'javascripts/main.coffee' do
        javascript.output_path.extname.should == '.js'
      end
    end
  end
  
  context 'with compression' do
    let(:javascript) { Massimo::Javascript.new 'javascripts/main.js' }
    
    context 'using :min' do
      it 'compresses using JSMin' do
        Massimo.config.javascripts_compressor = :min
        with_file 'javascripts/main.js', 'function(number) { return number + 2; }' do
          javascript.render.should == 'function(number){return number+2;}'
        end
      end
    end
    
    context 'using :pack' do
      it 'compresses using Packr' do
        Massimo.config.javascripts_compressor = :pack
        with_file 'javascripts/main.js', 'function(number) { return number + 2; }' do
          javascript.render.should == 'function(a){return a+2}'
        end
      end
      
      context 'with configuration' do
        it 'pass configuration to Packr' do
          Massimo.config.javascripts_compressor = :pack
          Massimo.config.packr = { :shrink_vars => false }
          with_file 'javascripts/main.js', 'function(number) { return number + 2; }' do
            javascript.render.should == 'function(number){return number+2}'
          end
        end
      end
    end
    
    context 'using :yui' do
      it 'compresses using YUI::JavaScriptCompressor' do
        Massimo.config.javascripts_compressor = :yui
        with_file 'javascripts/main.js', 'function(number) { return number + 2; }' do
          javascript.render.should == 'function(a){return a+2};'
        end
      end
      
      context 'with configuration' do
        it 'pass configuration to YUI::JavaScriptCompressor' do
          Massimo.config.javascripts_compressor = :yui
          Massimo.config.yui = { :munge => false }
          with_file 'javascripts/main.js', 'function(number) { return number + 2; }' do
            javascript.render.should == 'function(number){return number+2};'
          end
        end
      end
    end
  end
end