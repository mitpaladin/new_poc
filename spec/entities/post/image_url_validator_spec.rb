
require 'spec_helper'

require 'post/image_url_validator'

shared_examples 'it is invalid without a valid body' do
  it 'is not recognised as valid' do
    expect(obj).not_to be_valid
  end

  it 'has one error' do
    expect(obj).to have(1).error
  end

  it 'reports that the body may not be empty if no image URL' do
    expected = {
      image_url: 'may not be empty if body is missing or empty'
    }
    expect(obj.errors.first).to eq expected
  end
end

# ############################################################################ #

# Shared example group 'it is valid' defined in `title_validator_spec.rb`.

# ############################################################################ #

shared_examples 'it is valid with a valid image URL attribute' do
  context 'and a valid image URL is specified in the attributes, it' do
    let(:image_url) { 'http://www.example.com/image1.png' }

    it_behaves_like 'it is valid'
  end # context 'and a valid body is specified in the attributes, it'
end

# ############################################################################ #
# ############################################################################ #
# ############################################################################ #

# Namespace containing all application-defined entities.
module Entity
  describe Post::ImageUrlValidator do
    let(:attributes) { FancyOpenStruct.new body: body, image_url: image_url }
    let(:obj) { described_class.new attributes }

    context 'when no body is specified in the attributes' do
      let(:body) { nil }

      it_behaves_like 'it is valid with a valid image URL attribute'

      description = 'and the image URL specified in the attributes is invalid' \
        ' because'
      context description do
        context 'it is missing, it' do
          let(:image_url) { nil }

          it_behaves_like 'it is invalid without a valid body'
        end # context 'it is missing, it'

        context 'it is blank, it' do
          let(:image_url) { '     ' }

          it_behaves_like 'it is invalid without a valid body'
        end # context 'it is blank, it'
      end # context 'and the image URL ... in the attributes is invalid because'
    end # context 'when no body is specified in the attributes'

    context 'when a body is specified in the attributes' do
      let(:body) { 'A Valid Body' }

      it_behaves_like 'it is valid with a valid image URL attribute'

      description = 'and the image URL specified in the attributes is invalid' \
        ' because'
      context description do
        context 'it is missing, it' do
          let(:image_url) { nil }

          it_behaves_like 'it is valid'
        end # context 'it is missing, it'

        context 'it is blank, it' do
          let(:image_url) { '    ' }

          it_behaves_like 'it is valid'
        end # context 'it is blank, it'
      end # context 'and the image URL ... in the attributes is invalid because'
    end # context 'when a body is specified in the attributes'
  end # describe Post::ImageUrlValidator
end
