
require 'spec_helper'

require 'posts/byline_builder'

require_relative 'byline_builder/correct_containing_tags.rb'
require_relative 'byline_builder/formatted_time_tag'

# POROs that act as presentational support for entities.
module Decorations
  describe Posts::BylineBuilder do
    let(:author_name) { 'Some User' }
    let(:pubdate) { Time.parse '14 March 2015 12:34:56' }

    describe 'initialisation' do
      it 'accepts no parameters' do
        message = 'wrong number of arguments (1 for 0)'
        expect { described_class.new :testing }.to raise_error ArgumentError,
                                                               message
        expect { described_class.new }.not_to raise_error
      end
    end # describe 'initialisation'

    describe 'has a #build method that' do
      it 'requires one parameter' do
        expect(described_class.new.method(:build).arity).to eq 1
      end

      describe 'accepts a parameter that' do
        it 'is Hash-like' do
          attr_hash = { author_name: author_name, pubdate: pubdate }
          expect { described_class.new.build attr_hash }.not_to raise_error
          attr_obj = FancyOpenStruct.new attr_hash
          expect { described_class.new.build attr_obj }.not_to raise_error
          attr_instance = Class.new(ValueObject::Base) do
                            has_fields(*attr_hash.keys)
                          end.new attr_hash
          expect { described_class.new.build attr_instance }.not_to raise_error
        end

        it 'has an #attributes method returning a Hash-like object' do
          attr_hash = { author_name: author_name, pubdate: pubdate }
          post = Class.new do
                   attr_reader :attributes

                   def initialize(attributes)
                    @attributes = attributes
                   end
                 end.new attr_hash
          expect { described_class.new.build post }.not_to raise_error
        end
      end # describe 'accepts a parameter that'

      describe 'rejects a parameter that' do
        it 'is neither Hash-like nor has an #attributes method' do
          message = 'Post must expose its attributes either through an' \
            ' #attributes or #to_hash method'
          expect { described_class.new.build :bogus }.to raise_error message
        end

        it 'lacks an :author_name attribute' do
          attribs = { pubdate: pubdate }
          message = 'post must have an :author_name attribute value'
          expect { described_class.new.build attribs }.to raise_error message
        end
      end # describe 'rejects a parameter that'

      describe 'produces a return value as an HTML fragment' do
        let(:obj) { described_class.new }
        let(:actual) { obj.build post }

        context 'for a published post' do
          let(:post) { FactoryGirl.build :post, :published_post }

          it_behaves_like 'it has correct containing tags'

          it_behaves_like 'a correctly-formatted :time tag', 'Posted', :pubdate
        end # context 'for a published post'

        context 'for a draft post' do
          let!(:build_time) { Time.now.utc }
          let!(:post) { FactoryGirl.build :post }

          it_behaves_like 'it has correct containing tags'

          it_behaves_like 'a correctly-formatted :time tag', 'Drafted',
                          :updated_at
        end # context 'for a draft post'
      end # describe 'produces a return value as an HTML fragment'
    end # describe 'has a #build method that'
  end # describe Posts::BylineBuilder
end
