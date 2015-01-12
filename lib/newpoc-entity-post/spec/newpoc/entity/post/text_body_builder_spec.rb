
require 'spec_helper'

require 'newpoc/entity/post/text_body_builder'

module Newpoc
  module Entity
    class Post
      module SupportClasses
        describe TextBodyBuilder do
          let(:builder) { TextBodyBuilder.new }

          describe :build do
            description = 'wraps the "body" attribute of its param as a ' \
                'Markdown paragraph'
            it description do
              obj = OpenStruct.new(body: 'The Body')
              expect(builder.build obj).to eq "\nThe Body\n"
            end
          end # describe :build
        end # class Newpoc::Entity::Post::SupportClasses::TextBodyBuilder
      end # module Newpoc::Entity::Post::SupportClasses
    end # class Newpoc::Entity::Post
  end # module Newpoc::Entity
end # module Newpoc
