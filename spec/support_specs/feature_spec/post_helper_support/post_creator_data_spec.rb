
require 'support/feature_spec/post_helper_support/post_creator_data'

# Internal support-code module for FeatureSpecNewPostHelper class.
module PostHelperSupport
  # Specs for class that encapsulates/sequences data for post generation.
  describe PostCreatorData, support: true do
    let(:default_status) { 'public' }

    describe 'has a method returning a String or equivalent for' do
      let(:obj) { PostCreatorData.new }

      [:post_title, :post_body, :post_status].each do |method_sym|
        it "##{method_sym}" do
          expect(obj).to respond_to method_sym
          method_ret = obj.send method_sym
          expect(method_ret).to respond_to :to_str
          expect(method_ret).to respond_to :<=>
        end
      end
    end # describe 'has a method returning a String or equivalent for'

    describe 'has a #step method that' do
      let(:obj) { PostCreatorData.new }

      describe 'updates' do
        let(:pb_format) do
          'This is \*another\* post body\. \(Number (\d+?) in a series\.\)'
        end
        let(:patterns) do
          {
            post_title: Regexp.new(/Post Title (\d+?)/),
            post_body:  Regexp.new(pb_format)
          }
        end

        [:post_title, :post_body].each do |method_sym|
          description = "the internal field so that ##{method_sym} returns " \
              'the next value'
          it description do
            v1 = obj.send method_sym
            index1 = Integer(patterns[method_sym].match(v1)[1])
            expect(index1).to eq 1
            obj.step
            v2 = obj.send method_sym
            index2 = Integer(patterns[method_sym].match(v2)[1])
            expect(index2).to eq 2
          end
        end
      end # describe 'updates'

      describe 'accepts a parameter to use for the next instance status' do

        describe 'with acceptable values of' do
          %w(public draft).each do |status|
            it status do
              v1 = obj.post_status
              expect(v1).to eq 'public'
              obj.step status
              v2 = obj.post_status
              expect(v2).to eq status
            end
          end
        end # describe 'with acceptable values of'

        it 'ignoring illegal values and revierting to the default value' do
          obj.step 'bogus status value'
          expect(obj.post_status).to eq default_status
        end
      end # describe 'accepts a parameter to use for the next instance status'
    end # describe 'has a #step method that'

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

    describe :post_status.to_s do

      it 'defaults to "public" unless otherwise specified' do
        expect(PostCreatorData.new.post_status).to eq default_status
      end

      describe 'accepts explicit initialisation to' do
        %w(draft public).each do |status|
          it status do
            obj = PostCreatorData.new post_status: status
            expect(obj.post_status).to eq status
          end
        end
      end # describe 'accepts explicit initialisation to'

      it 'rejects invalid initialisation, reverting to default value' do
        obj = PostCreatorData.new post_status: 'bogus'
        expect(obj.post_status).to eq default_status
      end
    end # describe :post_status
  end # describe PostCreatorData
end # module PostHelperSupport
