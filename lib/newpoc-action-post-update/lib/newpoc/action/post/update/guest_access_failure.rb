
require 'newpoc/action/post/update/slug_based_error'

module Newpoc
  module Action
    module Post
      # Verifies that the current user is permitted to update a specified post.
      class Update
        module Internals
          # We don't allow Guests to edit posts. This JSON is what we broadcast.
          class GuestAccessFailure < SlugBasedError
            def initialize(source)
              super source, :guest_access_prohibited
            end
          end # class Newpoc::Action::Post::Update::...::GuestAccessFailure
        end # module Newpoc::Action::Post::Update::Internals
      end # class Newpoc::Action::Post::Update
    end
  end
end
