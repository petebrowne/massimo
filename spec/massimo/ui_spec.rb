require 'spec_helper'

describe Massimo::UI do
  describe '.say' do
    it 'prints out the given message to stdout' do
      mock($stdout).puts 'message'
      Massimo::UI.say 'message'
    end
    
    it 'does not send a Growl notification' do
      dont_allow(blank_module("Growl")).notify
      Massimo::UI.say 'message'
    end
    
    context 'with a color' do
      it 'prints out the message with the correct color code' do
        mock($stdout).puts "\e[31mmessage\e[0m"
        Massimo::UI.say 'message', :red
      end
    end
    
    context 'with :growl => true' do
      it 'sends a Growl Notification' do
        mock_module("Growl").notify('message', anything)
        Massimo::UI.say 'message', :growl => true
      end
      
      context 'and a color' do
        it 'sends an uncolored Growl Notification' do
          mock_module("Growl").notify('message', anything)
          Massimo::UI.say 'message', :red, :growl => true
        end
      end
    end
  end
  
  describe '.color' do
    it 'wraps the given message with the correct color code' do
      Massimo::UI.color('message', :red).should == "\e[31mmessage\e[0m"
    end
  end
  
  describe '.indent' do
    context 'within the block' do
      it 'indents messages' do
        Massimo::UI.indent do
          mock($stdout).puts '  message'
          Massimo::UI.say 'message'
        end
      end
      
      context 'with another .indent' do
        it 'further indents the messages' do
          Massimo::UI.indent do
            Massimo::UI.indent do
              mock($stdout).puts '    message'
              Massimo::UI.say 'message'
            end
          end
        end
      end
    end
    
    context 'after the block' do
      it 'returns to the original indent' do
        Massimo::UI.indent {}
        mock($stdout).puts 'message'
        Massimo::UI.say 'message'
      end
    end
  end
  
  describe '.report_errors' do
    context 'without an error' do
      it 'returns true' do
        Massimo::UI.report_errors do
          # no error
        end.should be_true
      end
    end
    
    context 'with an error' do
      it 'swallows the error' do
        expect {
          Massimo::UI.report_errors do
            raise ArgumentError
          end
        }.to_not raise_error
      end
    
      it 'reports the error' do
        mock($stdout) do |expect|
          expect.puts(/massimo/i)
          expect.puts(/ArgumentError/)
          expect.puts(/:\d+/)
        end
        Massimo::UI.report_errors do
          raise ArgumentError
        end
      end
      
      it 'returns false' do
        Massimo::UI.report_errors do
          raise ArgumentError
        end.should be_false
      end
    end
  end
end