
module Newpoc
  module Action
    module Post
      # Verifies that the current user is permitted to update a specified post.
      class Update
        module Internals
          # Enforces that only permitted keys are included in update data.
          class PostDataFilter
            def initialize(post_data)
              @post_data = post_data
            end

            # Why the FancyOpenStruct? Because we're handed a Hash-like thing
            # (coming from Rails, it's probably a HashWithIndifferentAccess)
            # that uses strings for keys but has its own implementation of
            # access by symbols or method calls. From our specs, we're using an
            # ordinary Hash (or a FOS), and we use symbols as keys by
            # convention. FancyOpenStruct lets us use that convention whether
            # the source data does or not. If we wind up handing it back to a
            # Rails blob that expects a HashWithIndifferentAccess, it'll Just
            # Work.
            def filter
              data = post_data.select { |attrib, _v| attrib_permitted? attrib }
              FancyOpenStruct.new data
            end

            private

            attr_reader :post_data

            def attrib_permitted?(attrib)
              valid_keys = [:title, :body, :image_url, :pubdate, :post_status]
              valid_keys.include? attrib.to_sym
            end
          end # class Newpoc::Action::Post::Update::Internals::PostDataFilter
        end # module Newpoc::Action::Post::Update::Internals
      end # class Newpoc::Action::Post::Update
    end
  end
end
