
require 'spec_helper'
require_relative 'shared_examples/an_entity_factory_for'

describe PostFactory do
  let(:klass) { PostFactory }
  let(:dao) { FactoryGirl.create :post, :saved_post }

  # it_behaves_like 'an entity factory for', Entity::Post
  it_behaves_like 'an entity factory for', Newpoc::Entity::Post
end
