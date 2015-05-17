
require 'spec_helper'

target_class = PostsController::Responder::CreateFailure::UnknownFailure
describe target_class, type: :request do
  describe 'has initialisation that' do
    it 'does not raise an error when passed in any Hash as a parameter' do
      @foo = 'bar'
      expect { described_class.new instance_values }.not_to raise_error
    end
  end # describe 'has initialisation that'

  describe 'has an .applies? class method that' do
    describe 'returns true when passed in *anything*, including' do
      after :each do
        expect(described_class.applies? @value).to be true
      end

      it 'nil' do
        @value = nil
      end

      it 'a Hash' do
        @value = { foo: 'bar', meaning: nil }
      end

      it 'a string' do
        @value = 'whatever'
      end
    end # describe 'returns true when passed in *anything*, including'
  end # describe 'has an .applies? class method that'

  describe 'has a #call instance method that' do
    let(:ivars) { { 'foo' => :bar, 'meaning' => 42 } }
    let(:obj) { described_class.new ivars }

    describe 'raises a runtime error whose message' do
      let(:message) do
        ret = ''
        begin
          obj.call params
        rescue RuntimeError => e
          ret = e.message
        end
        ret
      end
      let(:params) { { key1: 'value1', key2: nil, key3: :anything } }

      it 'starts with a line reading "Unknown failure"' do
        expect(message.lines.first).to eq "Unknown failure:\n"
      end

      it 'dumps the arguments it was called with after the first line' do
        expect(message.lines[1]).to eq "args: [\n"
        expect(message.lines[2]).to match "\[0\].*{\n$"
        params.each_with_index do |param, index|
          k, v = param.flatten
          expect(message.lines[3 + index]).to match "#{k}.+=>.+#{v}.+\n"
        end
        expect(message.lines[params.count + 3]).to match(/ +}\n/)
        expect(message.lines[params.count + 4]).to eq "]\n"
      end

      it 'dumps the instance variables it was initialised with at the end' do
        start_index = params.count + 5 # after 'args' output
        expect(message.lines[start_index]).to eq "ivars: {\n"
        ivars.each_with_index do |ivar, index|
          k, v = ivar.flatten
          match_str = "#{k}.+=>.+#{v}.+\n"
          expect(message.lines[start_index + index + 1]).to match match_str
        end
        expect(message.lines[ivars.count + start_index + 1]).to eq '}'
        expect(ivars.count + start_index + 2).to eq message.lines.count
      end
    end # describe 'raises a runtime error whose message'
  end # describe 'has a #call instance method that'
end # describe PostsController::Responder::CreateFailure::UnknownFailure
