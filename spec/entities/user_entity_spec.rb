
require 'spec_helper'

require_relative 'shared_examples/a_data_mapping_entity'

# Specs for persistence entity-layer representation for User.
describe UserEntity do
  let(:klass) { UserEntity }
  let(:user_name) { 'Joe Palooka' }
  let(:user_profile) { 'Whatever.' }
  let(:valid_subset) do
    {
      name: user_name,
      slug: user_name.parameterize,
      profile: user_profile
    }
  end
  let(:invalid_attribs) do
    {
      bogus: 'This is invalid',
      forty_two: 41
    }
  end
  let(:all_attrib_keys) do
    %w(created_at email name password password_confirmation profile slug
       updated_at).map(&:to_sym).to_a
  end

  it_behaves_like 'a data-mapping entity'
end # describe UserEntity
