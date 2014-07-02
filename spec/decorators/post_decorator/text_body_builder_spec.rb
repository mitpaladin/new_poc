
require 'spec_helper'

require 'post_decorator/text_body_builder'

class PostDecorator
  # Support class(es) for image post body builder.
  module SupportClasses
    describe TextBodyBuilder do
      let(:builder) { TextBodyBuilder.new h }

      describe :build do
        it 'wraps the "body" attribute of its caller in an HTML paragraph' do
          obj = OpenStruct.new(body: 'The Body')
          expect(builder.build obj).to eq '<p>The Body</p>'
        end
      end # describe :build
    end # describe TextBodyBuilder
  end # module PostDecorator::SupportClasses
end # class PostDecorator
