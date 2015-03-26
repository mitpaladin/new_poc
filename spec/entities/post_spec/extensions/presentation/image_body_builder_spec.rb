
require 'spec_helper'

# FIXME: HACK - Why isn't the source being autoloaded?
aepep_prefix = '../../../../../app/entities/post/extensions/presentation'
require_relative "#{aepep_prefix}/image_body_builder"

describe Entity::Post::Extensions::Presentation::ImageBodyBuilder do
  it 'is initialised with one optional parameter' do
    expect { described_class.new }.not_to raise_error
    param = -> (_param) { 'foo' }
    expect { described_class.new param }.not_to raise_error
  end

  describe 'has a #build method that' do
    let(:body) { 'BODY' }
    let(:image_url) { 'IMAGE_URL' }
    let(:post_params) { { body: body, image_url: image_url } }

    describe 'takes a parameter object which must supply an accessor for' do
      let(:builder) do
        Class.new do
          def to_html(markup)
            ['BODY MARKUP FOLLOWS', markup, 'BODY MARKUP ENDS'].join "\n"
          end
        end.new
      end
      let(:obj) { described_class.new builder }

      after :each do
        params = post_params.reject { |k, _v| k == @key }
        post = FancyOpenStruct.new params
        expect(obj.build post).to eq @expected
      end

      it ':body' do
        @key = :body
        @expected = %(<figure><img src="#{image_url}"><figcaption>) \
          "BODY MARKUP FOLLOWS\n\nBODY MARKUP ENDS</figcaption></figure>"
      end

      it ':image_url' do
        @key = :image_url
        @expected = %(<figure><img src=""><figcaption>) \
          "BODY MARKUP FOLLOWS\n#{body}\nBODY MARKUP ENDS</figcaption></figure>"
      end
    end # describe 'takes a parameter object which must supply an accessor for'

    it 'produces expected output given valid "post" entity' do
      obj = described_class.new
      post = FancyOpenStruct.new post_params
      expected = %(<figure><img src="#{image_url}"><figcaption>) \
        "<p>#{body}</p></figcaption></figure>"
      expect(obj.build post).to eq expected
    end
  end
end # describe Entity::Post::ImageBodyBuilder
