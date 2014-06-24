
require 'spec_helper'

require 'cco/blog_cco'

# Cross-layer conversion objects (CCOs).
module CCO
  describe BlogCCO do
    let(:klass) { BlogCCO }
    let(:blog_attribs) { FactoryGirl.attributes_for :blog_datum }
    let(:blog) { Blog.new }
    let(:impl) { BlogData.first }

    it 'has a .from_entity class method' do
      p = klass.public_method :from_entity
      expect(p.receiver).to be klass
    end

    it 'has a .to_entity class method' do
      p = klass.public_method :to_entity
      expect(p.receiver).to be klass
    end

    describe :from_entity do
      it 'raises an UnsupportedConversion error when called' do
        error = CCO::BlogCCO::UnsupportedConversionError
        message = 'Conversion from Blog entity unsupported at this time.'
        expect { klass.from_entity blog }.to raise_error error, message
      end
    end # describe :from_entity

    describe :to_entity do
      it 'does not raise an error when called with a BlogData parameter' do
        expect { klass.to_entity impl }.not_to raise_error
      end

      it 'returns a Blog instance when called with a BlogData instance' do
        expect(klass.to_entity impl).to be_a Blog
      end

      describe 'returns a Blog instance with correct values for' do
        let(:instance) { klass.to_entity impl }

        it 'title' do
          expect(instance.title).to eq impl.title
        end

        it 'subtitle' do
          expect(instance.subtitle).to eq impl.subtitle
        end
      end # describe 'returns a PostData instance with correct values for'
    end # describe :to_entity
  end # describe CCO::BlogCCO
end # module CCO
