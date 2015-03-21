
require 'spec_helper'

require_relative '../../app/entities/post'
# require 'entities/post'

# Namespace containing all application-defined entities.
module Entity
  describe Post do
    let(:author_name) { 'An Author' }
    let(:title) { 'A Title' }
    let(:valid_attributes) { { title: title, author_name: author_name } }

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
          expect(obj.title).to eq title
        end
      end # context 'valid attribute names as initialisation-hash keys'

      context 'a mixture of valid and invalid attribute names as keys' do
        it 'ignores the attributes specified with invalid keys' do
          obj = described_class.new title: title, foo: 'bar', meaning: 42
          actual = obj.attributes.reject { |_k, v| v.nil? }
          expect(actual.count).to eq 1
          expect(actual[:title]).to eq title
        end
      end # context 'a mixture of valid and invalid attribute names as keys'
    end # describe 'when instantiated with'

    describe 'has an #attributes method that' do
      let(:obj) { described_class.new valid_attributes }
      let(:actual) { obj.attributes }

      it 'returns the attributes passed to the initialiser' do
        valid_attributes.each_pair do |attrib, value|
          expect(actual[attrib]).to eq value
        end
      end

      it 'has nil values for all attributes not passed to the initialiser' do
        actual.keys.reject { |k| valid_attributes.key? k }.each do |attrib|
          expect(obj.attributes[attrib]).to be nil
        end
      end
    end # describe 'has an #attributes method that'
  end
end
