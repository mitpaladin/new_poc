
module Newpoc
  module Action
    module Post
      # Verifies that the current user is permitted to update a specified post.
      class Update
        module Internals
          # Current user not author of specified post. Bitch about it, as JSON.
          class NotAuthorFailure
            def initialize(current_user_name, post)
              @current_user_name = current_user_name
              @post = post
            end

            def to_json
              {
                current_user_name: @current_user_name,
                author_name:       @post.author_name
              }.to_json
            end
          end # class Newpoc::Action::Post::Update::Internals::NotAuthorFailure
        end # module Newpoc::Action::Post::Update::Internals
      end # class Newpoc::Action::Post::Update
    end
  end
end
