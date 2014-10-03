
# require 'spec_helper'

require_relative '../../../app/interactors/support/post_creation_param'

module DSO
  # Support classes/specs for DSOs
  module Support
    describe PostCreationParam do
      let(:klass) { PostCreationParam }
      describe 'can be constructed with' do
        it 'no parameters at all' do
          expect { klass.new }.not_to raise_error
        end

        it 'a single Hash parameter' do
          expect { klass.new {} }.not_to raise_error
        end

        it 'a single Hash parameter and a valid status string' do
          expect { klass.new({}, 'draft') }.not_to raise_error
        end
      end # describe 'can be constructed with'

      describe :status.to_s do

        %w(draft public).each do |str|
          it "can be set to '#{str}' by the initialiser" do
            obj = klass.new({}, str)
            expect(obj.status).to eq str
          end
        end

        it 'defaults to "draft" if not specified' do
          obj = klass.new
          expect(obj.status).to eq 'draft'
        end

        it 'reverts to the default value when an invalid string is specified' do
          obj = klass.new({}, 'whatever')
          expect(obj.status).to eq 'draft'
        end
      end # describe :status

      describe :to_h.to_sym do

        let(:all_keys) { [:title, :body, :image_url, :author_name] }
        context 'with no initial Hash specified' do
          let(:obj) { klass.new }
          it 'returns a Hash with all expected keys and empty string values' do
            expect(obj.to_h.keys).to eq all_keys
            obj.to_h.values.each { |v| expect(v).to eq '' }
          end
        end # context 'with no initial Hash specified'

        context 'with a partial Hash speciied' do
          let(:attribs) do
            {
              title:        'The Title',
              body:         'The Body',
              author_name:  'Joe Palooka'
            }
          end
          let(:obj) do
            klass.new attribs
          end

          it 'includes each specified value' do
            attribs.keys.each do |key|
              expect(obj.to_h[key]).to eq attribs[key]
            end
          end

          it 'sets all other values to empty strings' do
            all_keys.reject { |k| attribs.key? k }.each do |key|
              expect(obj.to_h[key]).to eq ''
            end
          end
        end # context 'with a partial Hash speciied' do
      end # describe :to_h
    end # describe DSO::Support::PostCreationParams
  end # module DSO::Support
end # module DSO
