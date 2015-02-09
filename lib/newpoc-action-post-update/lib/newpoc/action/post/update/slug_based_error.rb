
module Newpoc
  module Action
    module Post
      # Verifies that the current user is permitted to update a specified post.
      class Update
        module Internals
          # Build JSON based on source `slug` attribute.
          class SlugBasedError
            def initialize(source, error_key)
              the_slug = nil
              source.instance_eval { the_slug = slug }
              @slug = the_slug
              @error_key = error_key
            end

            def to_json
              {}.tap { |ret| ret[@error_key] = @slug }.to_json
            end
          end # class Newpoc::Action::Post::Update::Internals::SlugBasedError
        end # module Newpoc::Action::Post::Update::Internals
      end # class Newpoc::Action::Post::Update
    end
  end
end
