
require 'spec_helper'

require_relative 'shared_examples/the_initialize_method_for_a_repository'
require_relative 'shared_examples/the_add_method_for_a_repository'

describe PostRepository do
  let(:be_entity_for) do
    ->(entity) { be_saved_post_entity_for(entity) }
  end
  let(:dao_class) { PostDao }
  let(:entity_class) { PostEntity }
  let(:factory_class) { PostFactory }
  let(:klass) { PostRepository }
  let(:obj) { klass.new }
  let(:entity) do
    entity_class.new FactoryGirl
        .attributes_for(:post, :saved_post, :published_post)
  end
  let(:be_entity_for) { ->(entity) { be_saved_post_entity_for entity } }
  let(:saved_entity_matcher) do
    ->(result_entity, entity) \
        { expect(result_entity).to be_saved_post_entity_for entity }
  end
  let(:save_error_data) { { frobulator: 'is busted' } }

  describe :initialize.to_s do
    it_behaves_like 'the #initialize method for a Repository'
  end # describe :initialize

  fdescribe :add.to_s do
    it_behaves_like 'the #add method for a Repository'
  end # describe :add

end # describe PostRepository
