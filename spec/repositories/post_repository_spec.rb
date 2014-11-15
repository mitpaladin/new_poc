
require 'spec_helper'

require_relative 'shared_examples/the_initialize_method_for_a_repository'
require_relative 'shared_examples/the_add_method_for_a_repository'
require_relative 'shared_examples/the_all_method_for_a_repository'
require_relative 'shared_examples/the_delete_method_for_a_repository'
require_relative 'shared_examples/the_find_by_slug_method_for_a_repository'
require_relative 'shared_examples/the_update_method_for_a_repository'

describe PostRepository do
  let(:be_entity_for) do
    ->(entity) { be_saved_post_entity_for(entity) }
  end
  let(:dao_class) { PostDao }
  let(:entity_class) { PostEntity }
  let(:factory_class) { PostFactory }
  let(:klass) { PostRepository }
  let(:obj) { klass.new }
  let(:entity_attributes) do
    FactoryGirl.attributes_for :post, :saved_post, :published_post
  end
  let(:entity) do
    entity_class.new entity_attributes
  end
  let(:be_entity_for) { ->(entity) { be_saved_post_entity_for entity } }
  let(:saved_entity_matcher) do
    ->(result_entity, entity) \
        { expect(result_entity).to be_saved_post_entity_for entity }
  end
  let(:save_error_data) { { frobulator: 'is busted' } }
  let(:all_list_count) { 3 }
  let(:all_attributes_list) do
    FactoryGirl.attributes_for_list :post, all_list_count, :saved_post,
                                    :published_post
  end

  describe :initialize.to_s do
    it_behaves_like 'the #initialize method for a Repository'
  end # describe :initialize

  describe :add.to_s do
    it_behaves_like 'the #add method for a Repository'
  end # describe :add

  describe :all.to_s do
    it_behaves_like 'the #all method for a Repository'
  end # decribe :all

  describe :delete.to_s do
    it_behaves_like 'the #delete method for a Repository'
  end # decribe :delete

  describe :find_by_slug.to_s do
    it_behaves_like 'the #find_by_slug method for a Repository'
  end # describe :find_by_slug

  describe :update.to_s do
    let(:attribute_to_update) { :title }
    let(:updated_attribute) { '*Updated* meaningless title.' }

    it_behaves_like 'the #update method for a Repository'
  end # describe :update
end # describe PostRepository
