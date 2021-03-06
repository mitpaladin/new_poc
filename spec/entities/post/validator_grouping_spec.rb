
require 'spec_helper'

require 'post/validator_grouping'

# Namespace containing all application-defined entities.
module Entity
  describe Post::ValidatorGrouping do
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

        context 'body attribute AND image URL attribute' do
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
              { body: 'must be specified if image URL is omitted' },
              { image_url: 'must be specified if body is omitted' }
            ]
            expect(obj.errors).to eq expected
          end
        end # context 'body attribute AND image URL attribute'
      end # describe 'an entity with an invalid'
    end # describe 'validates core attributes such that'
  end # describe Post::ValidatorGrouping
end
