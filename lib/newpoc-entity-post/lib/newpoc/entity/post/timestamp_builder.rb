
module Newpoc
  module Entity
    # a Post is the domain entity for a blog-type post, with title, body, etc.
    class Post
      module SupportClasses
        # Simple and to the point.
        module TimestampBuilder
          # Provides uniform formatting for timestamps.
          def timestamp_for(the_time = Time.now)
            the_time.to_time.localtime.strftime timestamp_format
          end

          def timestamp_format
            '%a %b %e %Y at %R %Z (%z)'
          end
        end # module Newpoc::Entity::Post::SupportClasses::TimestampBuilder
      end # module Newpoc::Entity::Post::SupportClasses
    end # class Newpoc::Entity::Post
  end # module Newpoc::Entity
end # module Newpoc
