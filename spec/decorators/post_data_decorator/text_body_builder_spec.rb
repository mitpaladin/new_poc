
require 'spec_helper'

require 'post_data_decorator/text_body_builder'

class PostDataDecorator
  # Support class(es) for image post body builder.
  module SupportClasses
    describe TextBodyBuilder do
      let(:builder) { TextBodyBuilder.new h }

      describe :build do
        it 'wraps the "body" attribute of its param as a Markup paragraph' do
          obj = OpenStruct.new(body: 'The Body')
          expect(builder.build obj).to eq "\nThe Body\n"
        end
      end # describe :build
    end # describe TextBodyBuilder
  end # module PostDataDecorator::SupportClasses
end # class PostDataDecorator
