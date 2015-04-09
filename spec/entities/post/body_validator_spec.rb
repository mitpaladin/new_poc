
require 'spec_helper'

require 'post/body_validator'

shared_examples 'it is invalid without a valid image URL' do
  it 'is not recognised as valid' do
    expect(obj).not_to be_valid
  end

  it 'has one error' do
    expect(obj).to have(1).error
  end

  it 'reports that the body may not be empty if no image URL' do
    expected = {
      body: 'may not be empty if image URL is missing or empty'
    }
    expect(obj.errors.first).to eq expected
  end
end

# ############################################################################ #

shared_examples 'it is valid' do
  it 'is recognised as valid' do
    expect(obj).to be_valid
  end

  it 'has no errors' do
    expect(obj).to have(0).errors
  end
end

# ############################################################################ #

shared_examples 'it is valid with a valid body attribute' do
  context 'and a valid body is specified in the attributes, it' do
    let(:body) { 'A Body' }

    it_behaves_like 'it is valid'
  end # context 'and a valid body is specified in the attributes, it'
end

# ############################################################################ #
# ############################################################################ #
# ############################################################################ #

# Namespace containing all application-defined entities.
module Entity
  describe Post::BodyValidator do
    let(:attributes) { FancyOpenStruct.new body: body, image_url: image_url }
    let(:obj) { described_class.new attributes }

    context 'when no image URL is specified in the attributes' do
      let(:image_url) { nil }

      it_behaves_like 'it is valid with a valid body attribute'

      context 'and the body specified in the attributes is invalid because' do
        context 'it is missing, it' do
          let(:body) { nil }

          it_behaves_like 'it is invalid without a valid image URL'
        end # context 'it is missing, it'

        context 'it is blank, it' do
          let(:body) { '     ' }

          it_behaves_like 'it is invalid without a valid image URL'
        end # context 'it is blank, it'
      end # context 'and the body ... in the attributes is invalid because'
    end # context 'when no image URL is specified in the attributes'

    context 'when an image URL is specified in the attributes' do
      let(:image_url) { 'http://www.example.com/image1.png' }

      it_behaves_like 'it is valid with a valid body attribute'

      context 'and the body specified in the attributes is invalid because' do
        context 'it is missing, it' do
          let(:body) { nil }

          it_behaves_like 'it is valid'
        end # context 'it is missing, it'

        context 'it is blank, it' do
          let(:body) { '    ' }

          it_behaves_like 'it is valid'
        end # context 'it is blank, it'
      end # context 'and the body ... in the attributes is invalid because'
    end # context 'when an image URL is specified in the attributes'
  end # describe Post::BodyValidator
end
