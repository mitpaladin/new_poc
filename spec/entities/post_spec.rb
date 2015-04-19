
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
            author_name: valid_attributes[:author_name]
          }
          string_attrs['title'] = valid_attributes[:title]
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

    describe 'has an #errors method that' do
      it 'returns an ActiveModel::Errors instance' do
        expect(described_class.new({}).errors).to be_an ActiveModel::Errors
      end

      it 'reports that a valid instance has no errors' do
        obj = described_class.new valid_attributes
        expect(obj.errors).to be_empty
        expect(obj).to be_valid
      end

      describe 'reports that an invalid instance' do
        let(:attribs) { valid_attributes.merge author_name: nil, title: '' }
        let(:obj) { described_class.new attribs }

        before :each do
          obj.valid?
        end

        it 'has the correct number of errors' do
          expect(obj.errors).to have(2).messages
        end

        it 'must have a value for the :author_name attribute' do
          expected = 'Author name must be present'
          expect(obj.errors.full_messages).to include expected
        end

        it 'must have a value for the :title attribute that is not blank' do
          expect(obj.errors.full_messages).to include 'Title must not be blank'
        end
      end # describe 'reports that an invalid instance'
    end # describe 'has an #errors method that'

    describe 'has a #to_json method that serialises an instance' do
      let(:obj) { described_class.new(attributes).tap(&:valid?) }

      context 'with no errors' do
        let(:attributes) do
          FactoryGirl.attributes_for :post, :image_post, :saved_post,
                                     :published_post
        end

        describe 'serialises a Hash with' do
          let(:new_obj) { JSON.load obj.to_json }

          it 'keys matching the keys of the original attributes as strings' do
            expect(new_obj).to be_a Hash
            expect(new_obj.keys).to eq attributes.stringify_keys.keys
          end

          it 'values matching string values of the original attributes' do
            # attributes[:pubdate] is a TimeWithZone-like thing, not a string
            new_pubdate = new_obj.delete 'pubdate'
            original_pubdate = attributes.delete :pubdate
            expect(new_obj.symbolize_keys).to eq attributes
            expect(new_pubdate.to_json).to eq original_pubdate.to_json
          end
        end # describe 'serialises a Hash with'
      end # context 'with no errors'

      describe 'with errors that' do
        let(:attributes) do
          FactoryGirl.attributes_for :post, :image_post, :saved_post,
                                     :published_post,
                                     title: '', author_name: nil
        end

        describe 'serialises a Hash with' do
          let(:new_obj) { JSON.load obj.to_json }

          it 'keys for the original attributes, plus "errors"' do
            expect(new_obj).to be_a Hash
            expected_keys = %w(errors) + attributes.stringify_keys.keys
            expect(new_obj.keys.sort).to eq expected_keys.sort
          end

          describe 'correct error information, including' do
            let(:error_info) { new_obj['errors'] }

            it 'an array of two Hashes' do
              expect(error_info).to respond_to :to_ary
              expect(error_info).to have(2).items
              error_info.each { |item| expect(item).to respond_to :to_hash }
            end

            describe 'with the' do
              it 'first error hash reporting a missing author name' do
                error = error_info.first
                expect(error.keys.first).to eq 'author_name'
                expect(error.values.first).to eq 'must be present'
              end

              it 'second error hash reporting a blank title' do
                error = error_info.last
                expect(error.keys.first).to eq 'title'
                expect(error.values.first).to eq 'must not be blank'
              end
            end # describe 'with the'
          end
        end # describe 'serialises a Hash with'
      end # describe 'with errors that'
    end # describe 'has a #to_json method that serialises an instance'

    describe 'has a #published? method that, when called on an entity that' do
      context 'has a :pubdate attribute value that' do
        let(:attributes) { valid_attributes.merge pubdate: Time.zone.now }

        it 'returns true' do
          expect(described_class.new(attributes)).to be_published
        end
      end # context 'has a :pubdate attribute value that'

      context 'does not have a :pubdate attribute value that' do
        it 'returns false' do
          expect(described_class.new(valid_attributes)).not_to be_published
        end
      end # context 'does not have a :pubdate attribute value that'
    end # describe 'has a #published? method ... when called on an entity that'

    describe 'has a #persisted? method that, when called on an entity that' do
      context 'has a :slug attribute value that' do
        let(:attributes) do
          valid_attributes.merge slug: valid_title.parameterize
        end

        it 'returns true' do
          expect(described_class.new(attributes)).to be_persisted
        end
      end # context 'has a :slug attribute value that'

      context 'does not have a :slug attribute value that' do
        let(:attributes) { valid_attributes }

        it 'returns false' do
          expect(described_class.new(attributes)).not_to be_persisted
        end
      end # context 'does not have a :slug attribute value that'
    end # describe '... #persisted? method that, when called on an entity that'
  end # describe Post
end
