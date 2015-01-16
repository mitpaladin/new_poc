
require 'spec_helper'

require 'newpoc/entity/post/text_body_builder'

# The `#body_markup` method requires and uses the MarkdownHtmlConverter service,
# which is now packaged separately from this component. That's fine, in the app
# and its specs...but unit tests at this level can't deal with that, because
# Rubygems' dependency mechanism expects dependencies to be in a gem repo,
# somewhere it can grab them from. That doesn't work with unbuilt dependencies.
def mock_body_markup_for(builder, body, ret = body.to_s)
  allow(builder).to receive(:body_markup).with(body).and_return ret
end

module Newpoc
  module Entity
    class Post
      # *Private* support classes used by Post entity class.
      module SupportClasses
        describe TextBodyBuilder do
          let(:builder) { TextBodyBuilder.new }

          # Yes, this is a crock. Yes, this is basically just proving that the
          # mock we set up is returning what we give it. See the novella above
          # `mock_body_markup_for` for an explanation of why that is.
          describe :build do
            description = 'wraps the "body" attribute of its param as a ' \
                'Markdown paragraph'
            it description do
              body_text = 'The Body'
              obj = OpenStruct.new body: body_text
              mock_body_markup_for builder, body_text
              expect(builder.build obj).to eq body_text
            end
          end # describe :build
        end # class Newpoc::Entity::Post::SupportClasses::TextBodyBuilder
      end # module Newpoc::Entity::Post::SupportClasses
    end # class Newpoc::Entity::Post
  end # module Newpoc::Entity
end # module Newpoc
