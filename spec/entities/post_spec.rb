
require 'spec_helper'

require 'post'

# Namespace containing all application-defined entities.
module Entity
  describe Post do
    let(:author_name) { 'An Author' }
    let(:valid_attributes) do
      {
        author_name: author_name,
        body: valid_body,
        image_url: valid_image_url,
        title: valid_title
      }
    end
    let(:valid_body) { 'A Body' }
    let(:valid_image_url) { 'http://www.example.com/image1.png' }
    let(:valid_title) { 'A Title' }

    describe 'supports initialisation' do
      describe 'raising no error when called with' do
        it 'valid attribute names as Hash keys' do
          expect { described_class.new valid_attributes }.not_to raise_error
        end

        it 'invalid attribute names as Hash keys' do
          invalid_attributes = { foo: 'bar', baz: 42 }
          expect { described_class.new invalid_attributes }.not_to raise_error
        end
      end # describe 'raising no error when called with'

      describe 'raising an error when called with' do
        it 'no parameters' do
          message = 'wrong number of arguments (0 for 1)'
          expect { described_class.new }.to raise_error ArgumentError, message
        end
      end # describe 'raising an error when called with'
    end # describe 'supports initialisation'

    describe 'when instantiated with' do
      context 'valid attribute names as initialisation-hash keys' do
        let(:obj) { described_class.new valid_attributes }

        it 'initialises the named attributes to specified values' do
          expect(obj.title).to eq 'A Title'
          expect(obj.author_name).to eq author_name
        end

        it 'when keys are specified either as strings or symbols' do
          string_attrs = {
            author_name: valid_attributes[:author_name],
            "title": valid_attributes[:title]
          }
          obj = described_class.new string_attrs
          expect(obj.title).to eq 'A Title'
        end
      end # context 'valid attribute names as initialisation-hash keys'

      context 'a mixture of valid and invalid attribute names as keys' do
        let(:attribs) { { foo: 'bar', sense: nil }.merge valid_attributes }
        let(:obj) { described_class.new attribs }

        it 'initialises the valid attributes as specified' do
          expect(obj.title).to eq valid_attributes[:title]
          expect(obj.author_name).to eq valid_attributes[:author_name]
        end

        it 'ignores the attributes specified with invalid keys' do
          expect(obj).not_to respond_to :foo
          expect(obj).not_to respond_to :sense
        end
      end # context 'a mixture of valid and invalid attribute names as keys'
    end # describe 'when instantiated with'

    describe 'validates core attributes such that' do
      context 'an entity with valid attributes' do
        let(:obj) { described_class.new valid_attributes }

        it 'is recognised as valid' do
          expect(obj).to be_valid
        end

        it 'has no errors' do
          expect(obj.errors).to be_empty
        end
      end # context 'an entity with valid attributes'

      describe 'an entity with an invalid' do
        let(:obj) { described_class.new attributes }

        context 'title attribute' do
          let(:attributes) { valid_attributes.merge title: title }
          let(:title) { " \nAn\t Invalid Title\r\n" }

          it 'is recognised as invalid' do
            expect(obj).not_to be_valid
          end

          it 'reports three errors' do
            expect(obj).to have(3).errors
          end

          it 'reports each type of invalid whitespace in the title' do
            [
              { title: 'must not have leading whitespace' },
              { title: 'must not have trailing whitespace' },
              { title: 'must not have leading whitespace' }
            ].each do |expected|
              expect(obj.errors).to include expected
            end
          end
        end # context 'title attribute'

        context 'body attribute' do
          let(:attributes) { valid_attributes.merge invalid_attributes }
          let(:invalid_attributes) { { body: nil, image_url: nil } }

          it 'is recognised as invalid' do
            expect(obj).not_to be_valid
          end

          it 'reports two errors' do
            expect(obj).to have(2).errors
          end

          it 'reports that either the body or image URL must be present' do
            expected = [
              { body: 'may not be empty if image URL is missing or empty' },
              { image_url: 'may not be empty if body is missing or empty' }
            ]
            expect(obj.errors).to eq expected
          end
        end
      end # describe 'an entity with an invalid'
    end # describe 'validates core attributes such that'
  end # describe Post
end
