require 'spec_helper'

describe Massimo::Javascript do
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
        mock(CoffeeScript).compile('number: 42', { :bare => false }) { '' }
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
    
    context 'using :min' do
      it 'compresses using JSMin' do
        Massimo.config.javascripts_compressor = :min
        with_file 'javascripts/main.js', code do
          mock(JSMin).minify(code) { '' }
          javascript.render
        end
      end
    end
    
    context 'using :pack' do
      it 'compresses using Packr' do
        Massimo.config.javascripts_compressor = :pack
        with_file 'javascripts/main.js', code do
          mock(Packr).pack(code, :shrink_vars => true) { '' }
          javascript.render
        end
      end
      
      context 'with configuration' do
        it 'passes configuration to Packr' do
          Massimo.config.javascripts_compressor = :pack
          Massimo.config.packr = { :shrink_vars => false }
          with_file 'javascripts/main.js', code do
            mock(Packr).pack(code, :shrink_vars => false) { '' }
            javascript.render
          end
        end
      end
    end
    
    context 'using :yui' do
      it 'compresses using YUI::JavaScriptCompressor' do
        Massimo.config.javascripts_compressor = :yui
        with_file 'javascripts/main.js', code do
          compressor = mock!.compress(code) { '' }.subject
          mock(YUI::JavaScriptCompressor).new(:munge => true) { compressor }
          javascript.render
        end
      end
      
      context 'with configuration' do
        it 'passes configuration to YUI::JavaScriptCompressor' do
          Massimo.config.javascripts_compressor = :yui
          Massimo.config.yui = { :munge => false }
          with_file 'javascripts/main.js', code do
            compressor = mock!.compress(code) { '' }.subject
            mock(YUI::JavaScriptCompressor).new(:munge => false) { compressor }
            javascript.render
          end
        end
      end
    end
    
    context 'using :closure' do
      it 'compresses using Closure::Compiler' do
        Massimo.config.javascripts_compressor = :closure
        with_file 'javascripts/main.js', code do
          compiler = mock!.compile(code) { '' }.subject
          mock(Closure::Compiler).new({}) { compiler }
          javascript.render
        end
      end
      
      context 'with configuration' do
        it 'passes configuration to Closure::Compiler' do
          Massimo.config.javascripts_compressor = :closure
          Massimo.config.closure = { :compilation_level => 'ADVANCED_OPTIMIZATIONS' }
          with_file 'javascripts/main.js', code do
            compiler = mock!.compile(code) { '' }.subject
            mock(Closure::Compiler).new(:compilation_level => 'ADVANCED_OPTIMIZATIONS') { compiler }
            javascript.render
          end
        end
      end
    end
  end
end