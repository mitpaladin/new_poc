
require 'spec_helper'

require_relative 'shared_examples/a-data-mapping-entity'

# Specs for persistence entity-layer representation for User.
describe PostEntity do
  let(:klass) { PostEntity }
  let(:author_name) { 'Joe Palooka' }
  let(:title) { 'The Title' }
  let(:valid_subset) do
    {
      title: title,
      slug: title.parameterize,
      author_name: author_name,
      body: 'The Body'
    }
  end
  let(:invalid_attribs) do
    {
      bogus: 'This is invalid',
      forty_two: 41
    }
  end
  let(:all_attrib_keys) do
    %w(author_name body image_url slug title pubdate created_at updated_at)
       .map(&:to_sym).to_a
  end

  it_behaves_like 'a data-mapping entity'
end # describe PostEntity
