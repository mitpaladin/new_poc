
require 'spec_helper'

require_relative '../../app/entities/post'
# require 'entities/post'
require_relative 'post_spec/markup_test_builder'

# Namespace containing all application-defined entities.
module Entity
  describe Post do
    let(:author_name) { 'An Author' }
    let(:body) { 'A Post Body Would Go Here.' }
    let(:guest_user_name) { 'Guest User' }
    let(:image_url) { 'http://www.example.com/image1.png' }
    let(:slug) { title.parameterize }
    let(:title) { 'A Title' }
    let(:valid_attributes) do
      {
        author_name: author_name,
        body: body,
        image_url: image_url,
        title: title
      }
    end

    describe 'supports initialisation' do
      describe 'raising no error when called with' do
        it 'valid attribute names as Hash keys' do
          expect { described_class.new valid_attributes }.not_to raise_error
        end

        it 'invalid attribute names as Hash keys' do
          invalid_attributes = { foo: 'bar', baz: 42 }
          expect { described_class.new invalid_attributes }.not_to raise_error
        end
      end # describe 'raising no error when called with'

      describe 'raising an error when called with' do
        it 'no parameters' do
          message = 'wrong number of arguments (0 for 1)'
          expect { described_class.new }.to raise_error ArgumentError, message
        end
      end # describe 'raising an error when called with'
    end # describe 'supports initialisation'

    describe 'when instantiated with' do
      context 'valid attribute names as initialisation-hash keys' do
        let(:obj) { described_class.new valid_attributes }

        it 'initialises the named attributes to specified values' do
          expect(obj.title).to eq 'A Title'
          expect(obj.author_name).to eq author_name
        end

        it 'when keys are specified either as strings or symbols' do
          string_attrs = {
            author_name: valid_attributes[:author_name],
            "title": valid_attributes[:title]
          }
          obj = described_class.new string_attrs
          expect(obj.title).to eq title
        end
      end # context 'valid attribute names as initialisation-hash keys'

      context 'a mixture of valid and invalid attribute names as keys' do
        it 'ignores the attributes specified with invalid keys' do
          obj = described_class.new title: title, foo: 'bar', meaning: 42
          actual = obj.attributes.reject { |_k, v| v.nil? }
          expect(actual.count).to eq 1
          expect(actual[:title]).to eq title
        end
      end # context 'a mixture of valid and invalid attribute names as keys'
    end # describe 'when instantiated with'

    describe 'has an #attributes method that' do
      let(:obj) { described_class.new valid_attributes }
      let(:actual) { obj.attributes }

      it 'returns the attributes passed to the initialiser' do
        valid_attributes.each_pair do |attrib, value|
          expect(actual[attrib]).to eq value
        end
      end

      it 'has nil values for all attributes not passed to the initialiser' do
        actual.keys.reject { |k| valid_attributes.key? k }.each do |attrib|
          expect(obj.attributes[attrib]).to be nil
        end
      end
    end # describe 'has an #attributes method that'

    describe 'has a #persisted? method that' do
      # let(:valid_attributes) { { title: title, author_name: author_name } }
      let(:attributes_with_slug) { valid_attributes.merge slug: slug }

      it 'returns true if the "slug" attribute is present' do
        expect(described_class.new attributes_with_slug).to be_persisted
      end

      it 'returns false if the "slug" attribute is not present' do
        expect(described_class.new valid_attributes).not_to be_persisted
      end
    end # describe 'has a #persisted? method that'

    describe 'has a #valid? method that returns' do
      describe 'true when initialised with' do
        after :each do
          expect(described_class.new @attribs).to be_valid
        end

        it 'an author name, title and body' do
          @attribs = { author_name: author_name, title: title, body: body }
        end

        it 'an author name, title and image URL' do
          @attribs = {
            author_name: author_name,
            title: title,
            image_url: image_url
          }
        end

        it 'an author name, title, image URL and body' do
          @attribs = {
            author_name: author_name,
            title: title,
            image_url: image_url,
            body: body
          }
        end
      end # describe 'true when initialised with'

      describe 'false when initialised with' do
        after :each do
          expect(described_class.new @attribs).not_to be_valid
        end

        it 'no title' do
          @attribs = valid_attributes.reject { |k, _v| k == :title }
        end

        describe 'a title which has' do
          after :each do
            @attribs = valid_attributes.merge title: @title
          end

          it 'leading whitespace' do
            @title = " #{title}"
          end

          it 'traiing whitespace' do
            @title = "#{title} "
          end
        end # describe 'a title which has'

        it 'no author name' do
          @attribs = valid_attributes.reject { |k, _v| k == :author_name }
        end

        describe 'an author name which has' do
          after :each do
            @attribs = valid_attributes.merge author_name: @author_name
          end

          it 'leading whitespace' do
            @author_name = " #{author_name}"
          end

          it 'trailing whitespace' do
            @author_name = "#{author_name} "
          end

          it 'the same value as the guest user name' do
            @author_name = guest_user_name
          end
        end # describe 'an author name which has'

        it 'both a missing image URL and a missing body' do
          @attribs = valid_attributes.reject do |k, _v|
            [:image_url, :body].include? k
          end
        end
      end # describe 'false when initialised with'
    end # describe 'has a #valid? method that returns'

    ############################################################################
    ############################################################################
    ############################################################################
    # `#build_body` and `#build_byline` (and arguably `#post_status`) DO NOT   #
    # BELONG in a "core domain entity". They are *explicitly* presentational   #
    # details. They originated in helpers and decorators when this was a more  #
    # traditional Rails-Way app; got lumped into the User entity as temporary  #
    # expedients, and have long since outlived their welcome.                  #
    ############################################################################
    ############################################################################
    ############################################################################
    describe 'has a #build_body method that' do
      let(:post) { described_class.new valid_attributes }

      it 'accepts one optional parameter' do
        method = post.public_method :build_body
        expect(method.arity).to eq(-1)
      end

      describe 'returns the correct markup for' do
        after :each do
          markup = @post.build_body @test_builder
          expect(markup).to eq 'expected markup'
          expect(@test_builder.errors).to be_empty
        end

        xit 'an image post' do
          @post = post
          @test_builder = MarkupTestBuilder.new @post, 'ImageBodyBuilder'
        end

        it 'a text post'
      end # describe 'returns the correct markup for'
    end # describe 'has a #build_body method that'
  end
end