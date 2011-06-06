require 'spec_helper'

describe Massimo::Javascript do
  describe '#extension' do
    context 'with multiple extensions' do
      it 'should return the first extension' do
        with_file 'file.js.coffee' do
          Massimo::Javascript.new('file.js.coffee').extension.should == '.js'
        end
      end
    end
    
    context 'with a single Tilt registered extension' do
      it 'should default to .js' do
        with_file 'file.coffee' do
          Massimo::Javascript.new('file.coffee').extension.should == '.js'
        end
      end
    end
    
    context 'with a single unregistered extension' do
      it 'should be that extension' do
        with_file 'file.json' do
          Massimo::Javascript.new('file.json').extension.should == '.json'
        end
      end
    end
  end
  
  context 'with normal .js files' do
    let(:javascript) { Massimo::Javascript.new 'javascripts/main.js' }
    
    it 'copies content' do
      with_file 'javascripts/main.js', 'var number = 42;' do
        javascript.render.should == "var number = 42;"
      end
    end
    
    it 'concats using Sprockets' do
      within_construct do |c|
        c.file 'javascripts/main.js', '//= require "_plugin.js"'
        c.file 'javascripts/_plugin.js', 'var number = 42;'
        javascript.render.should == "var number = 42;"
      end
    end
  end
  
  context 'with .coffee scripts' do
    let(:javascript) { Massimo::Javascript.new 'javascripts/main.coffee' }
    
    it 'renders using CoffeeScript' do
      with_file 'javascripts/main.coffee', 'number: 42' do
        mock_module("CoffeeScript").compile('number: 42', { :bare => false }) { '' }
        javascript.render
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
    let(:code)       { "function addTwo(number) { return number + 2; }\n" }
    
    context 'using :jsmin' do
      it 'compresses using JSMin' do
        Massimo.config.js_compressor = :jsmin
        with_file 'javascripts/main.js', code do
          mock_module("JSMin").minify(code) { '' }
          javascript.render
        end
      end
    end
    
    context 'using :packr' do
      it 'compresses using Packr' do
        Massimo.config.js_compressor = :packr
        with_file 'javascripts/main.js', code do
          mock_module("Packr").pack(code, {}) { '' }
          javascript.render
        end
      end
      
      context 'with configuration' do
        it 'passes configuration to Packr' do
          Massimo.config.js_compressor = :packr
          Massimo.config.js_compressor_options = { :shrink_vars => true }
          with_file 'javascripts/main.js', code do
            mock_module("Packr").pack(code, :shrink_vars => true) { '' }
            javascript.render
          end
        end
      end
    end
    
    context 'using :yui' do
      it 'compresses using YUI::JavaScriptCompressor' do
        Massimo.config.js_compressor = :yui_js
        with_file 'javascripts/main.js', code do
          compressor = mock!.compress(code) { '' }.subject
          mock_module("YUI::JavaScriptCompressor").new({}) { compressor }
          javascript.render
        end
      end
      
      context 'with configuration' do
        it 'passes configuration to YUI::JavaScriptCompressor' do
          Massimo.config.js_compressor = :yui_js
          Massimo.config.js_compressor_options = { :munge => true }
          with_file 'javascripts/main.js', code do
            compressor = mock!.compress(code) { '' }.subject
            mock_module("YUI::JavaScriptCompressor").new(:munge => true) { compressor }
            javascript.render
          end
        end
      end
    end
    
    context 'using :closure' do
      it 'compresses using Closure::Compiler' do
        Massimo.config.js_compressor = :closure
        with_file 'javascripts/main.js', code do
          compiler = mock!.compile(code) { '' }.subject
          mock_module("Closure::Compiler").new({}) { compiler }
          javascript.render
        end
      end
      
      context 'with configuration' do
        it 'passes configuration to Closure::Compiler' do
          Massimo.config.js_compressor = :closure
          Massimo.config.js_compressor_options = { :compilation_level => 'ADVANCED_OPTIMIZATIONS' }
          with_file 'javascripts/main.js', code do
            compiler = mock!.compile(code) { '' }.subject
            mock_module("Closure::Compiler").new(:compilation_level => 'ADVANCED_OPTIMIZATIONS') { compiler }
            javascript.render
          end
        end
      end
    end
    
    context 'using :uglifier' do
      it 'compresses using Uglifier' do
        Massimo.config.js_compressor = :uglifier
        with_file 'javascripts/main.js', code do
          compiler = mock!.compile(code) { '' }.subject
          mock_module("Uglifier").new({}) { compiler }
          javascript.render
        end
      end
      
      context 'with configuration' do
        it 'passes configuration to Uglifier' do
          Massimo.config.js_compressor = :uglifier
          Massimo.config.js_compressor_options = { :mangle => true }
          with_file 'javascripts/main.js', code do
            compiler = mock!.compile(code) { '' }.subject
            mock_module("Uglifier").new(:mangle => true) { compiler }
            javascript.render
          end
        end
      end
    end
  end
end