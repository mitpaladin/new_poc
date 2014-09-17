
require 'spec_helper'

shared_examples 'a form-attributes helper' do |form_name|

  describe ":#{form_name}_form_attributes" do
    it 'returns a Hash' do
      expect(subject).to be_a Hash
    end

    describe 'has top-level keys for' do
      [:html, :role, :url].each do |key|
        it ":#{key}" do
          expect(subject).to have_key key
        end
      end
    end # describe 'has top-level keys for'

    describe 'has an :html sub-hash that contains the correct values for' do
      it 'the :id key' do
        expect(subject[:html][:id]).to eq form_name
      end

      it 'the :class key' do
        classes = subject[:html][:class].split(/\s+/)
        expect(classes).to include 'form-horizontal'
        expect(classes).to include form_name
      end
    end # describe 'has an :html sub-hash that contains the correct values for'

    it 'has a :role item with the value "form" as an ARIA instruction' do
      expect(subject[:role]).to eq 'form'
    end
  end # describe ":#{form_name}_form_attributes"
end

describe PostsHelper do
  describe :new_post_form_attributes.to_s do
    subject { helper.new_post_form_attributes }

    it_behaves_like 'a form-attributes helper', 'new_post'

    it 'has a :url item with the value returned from the posts_path helper' do
      expected = helper.posts_path
      expect(subject[:url]).to eq expected
    end
  end # describe :new_post_form_attributes

  describe :edit_post_form_attributes.to_s do
    let(:post_data) { FactoryGirl.create :post_datum }
    subject { helper.send :edit_post_form_attributes, post_data }
    let(:form_name) { 'edit_post' }

    it_behaves_like 'a form-attributes helper', 'edit_post'

    description = 'has a :url item with the value returned from the post_path' \
        ' helper for a specific post'
    it description do
      expected = helper.post_path(post_data)
      expect(subject[:url]).to eq expected
    end
  end # describe :edit_post_form_attributes

  describe :status_select_options.to_s do

    context 'for an unpublished post' do
      let(:post) { FactoryGirl.build :post_datum, :new_post }
      let(:actual) { status_select_options post }
      let(:options) { actual.scan(Regexp.new '<option.+?</option>') }
      let(:selected) { options.select { |s| s.match(/selected\=/) } }

      it 'returns two HTML <option> tags' do
        expect(options.count).to eq 2
      end

      describe 'returns <option> tags for' do

        %w(draft public).each do |status|
          it status do
            regex = Regexp.new "value=\"#{status}\""
            match = options.select { |s| s.match regex }
            expect(match).not_to be nil
          end
        end
      end # describe 'returns <option> tags for'

      it 'has "draft" as the selected option' do
        expect(selected.first).to match(/value="draft"/)
      end
    end # context 'for an unpublished post'

    context 'for a published post' do
      let(:post) { FactoryGirl.build :post_datum, :saved_post, :public_post }
      let(:actual) { status_select_options post }
      let(:options) { actual.scan(Regexp.new '<option.+?</option>') }
      let(:selected) { options.select { |s| s.match(/selected\=/) } }

      it 'returns two HTML <option> tags' do
        expect(options.count).to eq 2
      end

      describe 'returns <option> tags for' do

        %w(draft public).each do |status|
          it status do
            regex = Regexp.new "value=\"#{status}\""
            match = options.select { |s| s.match regex }
            expect(match).not_to be nil
          end
        end
      end # describe 'returns <option> tags for'

      it 'has "public" as the selected option' do
        expect(selected.first).to match(/value="public"/)
      end
    end # context 'for a published post'
  end # describe :status_select_options
  # it_behaves_like 'post form-attributes helper', 'edit_post'
end # describe PostsHelper
