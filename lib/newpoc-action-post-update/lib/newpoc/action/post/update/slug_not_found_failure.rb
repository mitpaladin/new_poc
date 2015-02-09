
require 'newpoc/action/post/update/slug_based_error'

module Newpoc
  module Action
    module Post
      # Verifies that the current user is permitted to update a specified post.
      class Update
        module Internals
          # Specified slug isn't in the repo. Get JSON for error broadcast.
          class SlugNotFoundFailure < SlugBasedError
            def initialize(source)
              super source, :slug_not_found
            end
          end # class Newpoc::Action::Post::Update::...::SlugNotFoundFailure
        end # module Newpoc::Action::Post::Update::Internals
      end # class Newpoc::Action::Post::Update
    end
  end
end
