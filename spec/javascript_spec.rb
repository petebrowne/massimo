require File.expand_path('../spec_helper', __FILE__)

describe Massimo::Javascript do
  context 'with normal .js files' do
    let(:javascript) { Massimo::Javascript.new 'javascripts/main.js' }
    
    it 'should copy content' do
      within_construct do |c|
        c.file 'javascripts/main.js', 'var number = 42;'
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
      within_construct do |c|
        c.file 'javascripts/main.coffee', 'number: 42'
        javascript.render.should == "(function(){\n  var number;\n  number = 42;\n})();"
      end
    end
    
    it 'should output .js files' do
      within_construct do |c|
        c.file 'javascripts/main.coffee'
        javascript.output_path.extname.should == '.js'
      end
    end
  end
end
