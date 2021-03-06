
require 'spec_helper'
require_relative 'shared_examples/an_entity_factory_for'

describe PostFactory do
  let(:klass) { described_class }
  let(:dao) { FactoryGirl.create :post, :saved_post }

  it_behaves_like 'an entity factory for', described_class.entity_class
end
