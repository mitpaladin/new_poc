
require 'spec_helper'
require_relative 'shared_examples/an_entity_factory_for'

describe UserFactory do
  let(:klass) { UserFactory }
  let(:dao) { FactoryGirl.create :user, :saved_user }

  it_behaves_like 'an entity factory for', Newpoc::Entity::User
end
