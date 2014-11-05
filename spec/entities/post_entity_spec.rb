
require 'spec_helper'

require_relative 'shared_examples/a_data_mapping_entity'

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
  let(:draft_post) { klass.new valid_subset }
  let(:published_attribs) { valid_subset.merge pubdate: Time.now }
  let(:published_post) { klass.new published_attribs }

  it_behaves_like 'a data-mapping entity'

  describe :draft?.to_s do
    it 'returns false for a published post' do
      expect(published_post).not_to be_draft
    end

    it 'returns true for an unpublished post' do
      expect(draft_post).to be_draft
    end
  end # describe :draft?

  describe :published?.to_s do
    it 'returns true for a published post' do
      expect(published_post).to be_published
    end

    it 'returns false for an unpublished post' do
      expect(draft_post).not_to be_published
    end
  end
end # describe PostEntity
