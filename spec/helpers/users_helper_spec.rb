
require 'spec_helper'

require 'support/shared_examples/users_helper/a_profile_article_list'

describe UsersHelper do

  describe :profile_article_list.to_s do
    fragment_builder = lambda do |markup|
      Nokogiri.parse(markup).children.first
    end
    it_behaves_like 'a profile article list', fragment_builder
  end # describe :profile_article_list

  describe :profile_articles_row.to_s do
    let(:user) { FactoryGirl.create :user_datum }
    let(:fragment) do
      Nokogiri.parse(profile_articles_row user.name).children.first
    end

    it 'is a div.row#contrib-row element' do
      expect(fragment.name).to eq 'div'
      expect(fragment['class']).to eq 'row'
      expect(fragment['id']).to eq 'contrib-row'
    end

    it 'has two child elements' do
      expect(fragment).to have(2).children
    end

    describe 'contains a first child element that' do
      let(:element) { fragment.children.first }

      it 'is an h3 element' do
        expect(element.name).to eq 'h3'
      end

      it 'contains the expected text, including the user name' do
        expected = ['Articles Authored By', user.name].join ' '
        expect(element.content).to eq expected
      end
    end # describe 'contains a first child element that'

    describe 'contains a second child element that is a profile article list' do
      fragment_builder = lambda do |markup|
        Nokogiri.parse(markup).children.last
      end
      it_behaves_like 'a profile article list', fragment_builder
    end # describe 'contains a second child element...a profile article list'
  end # describe :profile_articles_row
end # describe UsersHelper
