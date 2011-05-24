require 'spec_helper'

describe Massimo::Stylesheet do
  describe '#extension' do
    context 'with multiple extensions' do
      it 'should return the first extension' do
        with_file 'file.css.scss' do
          Massimo::Stylesheet.new('file.css.scss').extension.should == '.css'
        end
      end
    end
    
    context 'with a single Tilt registered extension' do
      it 'should default to .css' do
        with_file 'file.scss' do
          Massimo::Stylesheet.new('file.scss').extension.should == '.css'
        end
      end
    end
    
    context 'with a single unregistered extension' do
      it 'should be that extension' do
        with_file 'file.jpg' do
          Massimo::Stylesheet.new('file.jpg').extension.should == '.jpg'
        end
      end
    end
  end
  
  context 'with normal .css files' do
    let(:stylesheet) { Massimo::Stylesheet.new('stylesheets/main.css') }
    
    it 'should render using Sass' do
      within_construct do |c|
        c.file 'stylesheets/main.css', '#header { font-size: 36px }'
        stylesheet.render.should == '#header { font-size: 36px }'
      end
    end
  end
  
  context 'with .sass styleheets' do
    let(:stylesheet) { Massimo::Stylesheet.new('stylesheets/main.sass') }
    
    it 'should render using Sass' do
      within_construct do |c|
        c.file 'stylesheets/main.sass', "#header\n  font-size: 36px"
        stylesheet.render.should == "#header {\n  font-size: 36px; }\n"
      end
    end
    
    it 'should import other .sass files' do
      within_construct do |c|
        c.file 'stylesheets/main.sass', '@import "base"'
        c.file 'stylesheets/_base.sass', "#header\n  font-size: 36px"
        stylesheet.render.should == "#header {\n  font-size: 36px; }\n"
      end
    end
    
    it 'should output .css files' do
      within_construct do |c|
        c.file 'stylesheets/main.sass'
        stylesheet.output_path.extname.should == '.css'
      end
    end
    
    it 'should use Sass options from config' do
      Massimo.config.sass = { :style => :compressed }
      within_construct do |c|
        c.file 'stylesheets/main.sass', "#header\n font-size: 36px"
        stylesheet.render.should == "#header{font-size:36px}\n"
      end
    end
  end
  
  context 'with .scss styleheets' do
    let(:stylesheet) { Massimo::Stylesheet.new('stylesheets/main.scss') }
    
    it 'should render using Sass' do
      within_construct do |c|
        c.file 'stylesheets/main.scss', "$size: 36px;\n#header { font-size: $size; }\n"
        stylesheet.render.should == "#header {\n  font-size: 36px; }\n"
      end
    end
  end
  
  context 'with .less stylesheets' do
    let(:stylesheet) { Massimo::Stylesheet.new('stylesheets/main.less') }
    
    it 'should render using Less' do
      within_construct do |c|
        c.file 'stylesheets/main.less', "@color: #000000;\n#header { color: @color; }"
        stylesheet.render.should == "#header { color: #000000; }\n"
      end
    end
    
    it 'should output .css files' do
      within_construct do |c|
        c.file 'stylesheets/main.less'
        stylesheet.output_path.extname.should == '.css'
      end
    end
  end
end