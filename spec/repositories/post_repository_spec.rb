
require 'spec_helper'

require_relative 'shared_examples/the_initialize_method_for_a_repository'

describe PostRepository do
  let(:dao_class) { PostDao }
  let(:entity_class) { PostEntity }
  let(:factory_class) { PostFactory }
  let(:klass) { PostRepository }
  let(:obj) { klass.new }
  let(:entity) do
    entity_class.new FactoryGirl
        .attributes_for(:post, :saved_post, :published_post)
  end
  let(:save_error_data) { { frobulator: 'is busted' } }

  describe :initialize.to_s do
    it_behaves_like 'the #initialize method for a Repository'
  end # describe :initialize

  describe :add.to_s do

    context 'on success' do
      let!(:result) { obj.add entity }

      it 'adds a new record to the database' do
        expect(dao_class.all).to have(1).record
      end

      fit 'returns the expected StoreResult' do
        expect(result).to be_success
        expect(result.errors).to be nil
        # beginning of what should go into be_saved_post_entity_for matcher
        [:author_name, :body, :image_url, :slug, :title, :pubdate]
            .each do |attr|
          expect(result.entity.send attr).to eq entity.send(attr)
        end
        # end of what should go into be_saved_post_entity_for matcher
        expect(result.entity).to be_saved_post_entity_for entity
      end
    end # context 'on success'

    context 'on failure' do
      let(:mockDao) do
        Class.new(dao_class) do
          def save
            errors.add :frobulator, 'is busted'
            false
          end
        end
      end
      let(:obj) do
        klass.new factory_class, mockDao
      end
      let(:result) { obj.add entity }

      it 'does not add a new record to the database' do
        expect(dao_class.all).to have(0).records
      end

      it 'returns the expected StoreResult' do
        expect(result).not_to be_success
        expect(result.entity).to be nil
        expect(result).to have(1).error
        error = result.errors.first
        expect(error[:field]).to eq save_error_data.keys.first.to_s
        expect(error[:message]).to eq save_error_data.values.first
      end
    end # context 'on failure'
  end # describe :add

end # describe PostRepository
