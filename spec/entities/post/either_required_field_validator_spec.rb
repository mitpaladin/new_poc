
require 'spec_helper'

require 'post/either_required_field_validator'

require_relative 'shared/valid_with_no_errors'
require_relative 'shared/invalid_without_valid_primary'
require_relative 'shared/a_primary_attribute'

# Namespace containing all application-defined entities.
module Entity
  describe Post::EitherRequiredFieldValidator do
    let(:attributes) { FancyOpenStruct.new first: attrib1, second: attrib2 }
    let(:obj) do
      described_class.new attributes: attributes, primary: :first,
                          other: :second
    end

    context 'when no secondary attribute is specified' do
      let(:attrib2) { nil }

      secondary_result = 'it is invalid without a valid primary attribute'
      it_behaves_like 'a primary attribute', secondary_result
    end # context 'when no secondary attribute is specified'

    context 'when a secondary attribute is specified' do
      let(:attrib2) { 'Secondary Attribute' }

      it_behaves_like 'a primary attribute', 'it is valid'
    end # context 'when a secondary attribute is specified'
  end # describe Post::EitherRequiredFieldValidator
end
