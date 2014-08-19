
require_relative 'post_creator_data'

# Internal support-code module for FeatureSpecNewPostHelper class.
module PostHelperSupport
  # Specs for class that encapsulates/sequences data for post generation.
  describe PostCreatorData do
    describe 'has a method returning a String or equivalent for' do
      let(:obj) { PostCreatorData.new }

      [:post_title, :post_body].each do |method_sym|
        it "##{method_sym}" do
          expect(obj).to respond_to method_sym
          method_ret = obj.send method_sym
          expect(method_ret).to respond_to :to_str
          expect(method_ret).to respond_to :<=>
        end
      end
    end # describe 'has a method returning a String or equivalent for'

    context 'by default' do
      let(:obj) { PostCreatorData.new }

      description = 'returns identical post titles from repeated calls to ' \
          '#post_title.to_s'
      it description do
        expected = 'Post Title 1'
        (1..50).each { expect(obj.post_title.to_s).to eq expected }
      end

      description = 'returns identical post bodies from repeated calls to ' \
          '#post_body.to_s'
      it description do
        expected = 'This is *another* post body. (Number 1 in a series.)'
        (1..50).each { expect(obj.post_body.to_s).to eq expected }
      end
    end # context 'by default'

    context 'specifying a post-title format' do
      let(:title_format) { 'Test Format %d' }
      let(:obj) { PostCreatorData.new post_title: title_format }

      description = 'repeated calls to the return object #to_s method return ' \
          'identical strings'
      it description do
        expected = format title_format, 1
        (1..50).each { expect(obj.post_title.to_s).to eq expected }
      end # describe 'repeated calls to...#to_s method return expected strings'
    end # context 'specifying a post-title format'

    context 'specifying a post-body format' do
      let(:body_format) { 'Test Body Format %d' }
      let(:obj) { PostCreatorData.new post_body: body_format }

      description = 'repeated calls to the return object #to_s method return ' \
          'identical strings'
      it description do
        expected = format body_format, 1
        (1..50).each { expect(obj.post_body.to_s).to eq expected }
      end # describe 'repeated calls to...#to_s method return expected strings'
    end # context 'specifying a post-body format'

    context 'specifying a post-start value' do
      let(:post_start) { 200 }
      let(:obj) { PostCreatorData.new post_start: post_start }

      it 'starts the sequence from the speciied parameter value' do
        expected = (post_start + 1).to_s
        (1..30).each do
          matches = obj.post_title.to_s.match(/.+? (\d+)/)
          expect(matches[1]).to eq expected
        end
      end
    end # context 'specifying a post-start value'
  end # describe PostCreatorData
end # module PostHelperSupport
