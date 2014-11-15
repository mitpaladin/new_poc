
require 'spec_helper'

require 'post_entity/text_body_builder'

class PostEntity
  # Support class(es) for image post body builder.
  module SupportClasses
    describe TextBodyBuilder do
      let(:builder) { TextBodyBuilder.new }

      describe :build do
        it 'wraps the "body" attribute of its param as a Markup paragraph' do
          obj = OpenStruct.new(body: 'The Body')
          expect(builder.build obj).to eq "\nThe Body\n"
        end
      end # describe :build
    end # describe TextBodyBuilder
  end # module PostEntity::SupportClasses
end # class PostEntity
