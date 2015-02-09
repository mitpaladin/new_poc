
require 'yajl/json_gem'

module Newpoc
  module Action
    module Post
      # Verifies that the current user is permitted to update a specified post.
      class Update
        module Internals
          # Current user not author of specified post. Bitch about it, as JSON.
          class UpdateFailure
            def initialize(slug, inputs)
              @slug = slug
              @inputs = inputs
            end

            def to_json
              Yajl.dump slug: @slug, inputs: @inputs
            end
          end # class Newpoc::Action::Post::Update::Internals::UpdateFailure
        end # module Newpoc::Action::Post::Update::Internals
      end # class Newpoc::Action::Post::Update
    end
  end
end
