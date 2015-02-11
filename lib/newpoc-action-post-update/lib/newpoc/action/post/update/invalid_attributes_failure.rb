
require 'yajl/json_gem'

module Newpoc
  module Action
    module Post
      # Verifies that the current user is permitted to update a specified post.
      class Update
        module Internals
          # Current user not author of specified post. Bitch about it, as JSON.
          class InvalidAttributesFailure
            def initialize(attributes)
              @attributes = attributes
            end

            def to_json
              Yajl.dump @attributes
            end
          end # class ...::...::Post::...::Internals::InvalidAttributesFailure
        end # module Newpoc::Action::Post::Update::Internals
      end # class Newpoc::Action::Post::Update
    end
  end
end
