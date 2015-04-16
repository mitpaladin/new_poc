
require 'spec_helper'

require 'post/validators/body'

require_relative '../shared/invalid_without_valid_image_url'
require_relative '../shared/valid_with_no_errors'
require_relative '../shared/valid_with_valid_body'
require_relative '../shared/a_body_attribute'

# Namespace containing all application-defined entities.
module Entity
  describe Post::Validators::Body do
    let(:attributes) { FancyOpenStruct.new body: body, image_url: image_url }
    let(:obj) { described_class.new attributes }

    context 'when no image URL is specified in the attributes' do
      let(:image_url) { nil }

      other_shared = 'it is invalid without a valid image URL'
      it_behaves_like 'a body attribute', other_shared
    end # context 'when no image URL is specified in the attributes'
  end # describe Post::Validators::Body
end
