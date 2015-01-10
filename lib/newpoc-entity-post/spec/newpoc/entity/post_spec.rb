
require 'spec_helper'

describe Newpoc::Entity::Post do
  let(:author_name) { 'Joe Palooka' }
  let(:image_url) { 'http://www.example.com/foo.png' }
  let(:title) { 'The Title' }
  let(:title_param) { 'the-title' }
  let(:body) { 'The Body' }
  let(:valid_subset) do
    {
      title: title,
      slug: title_param,
      author_name: author_name,
      body: body
    }
  end

  it 'has a version number' do
    expect(Newpoc::Entity::Post::VERSION).not_to be nil
  end

  describe 'supports initialisation' do
    describe 'succeeding' do
      it 'with any combination of valid field names' do
        expect { described_class.new valid_subset }.not_to raise_error
      end

      # it 'with invalid field names' do
      #   expect { described_class.new invalid_attribs }.not_to raise_error
      # end
    end # describe 'succeeding'
  end # describe 'supports initialisation'
end
