
require 'spec_helper'

require 'post/image_url_validator'

require_relative 'shared/invalid_without_valid_body'
require_relative 'shared/valid_with_valid_image_url'
require_relative 'shared/valid_with_no_errors'
require_relative 'shared/an_image_url_attribute'

# Namespace containing all application-defined entities.
module Entity
  describe Post::ImageUrlValidator do
    let(:attributes) { FancyOpenStruct.new body: body, image_url: image_url }
    let(:obj) { described_class.new attributes }

    context 'when no body is specified in the attributes' do
      let(:body) { nil }

      other_shared = 'it is invalid without a valid body'
      it_behaves_like 'an image URL attribute', other_shared
    end # context 'when no body is specified in the attributes'
  end # describe Post::ImageUrlValidator
end
