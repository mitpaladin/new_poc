
# Namespace containing all application-defined entities.
module Entity
  # The Post class encapsulates post-related domain logic of our "fancy" blog.
  # It delegates or defers implementation-specific details such as persistence,
  # user interface, etc.
  class Post
    # Presentation-ish methods used by current Post entity API.
    module Extensions
      # Presentation-oriented "decorator" methods and support.
      module Presentation
        # Presentation-ish timestamp builder, used by `BylineBuilder`.
        module TimestampBuilder
          def self.timestamp_for(the_time = Time.now)
            the_time.to_time.localtime.strftime timestamp_format
          end

          def self.timestamp_format
            '%a %b %e %Y at %R %Z (%z)'
          end
        end # module Entity::Post::Extensions::Presentation::TimestampBuilder
      end
    end
  end # class Entity::Post
end
