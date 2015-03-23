# Namespace containing all application-defined entities.
module Entity
  # The Post class encapsulates post-related domain logic of our "fancy" blog.
  # It delegates or defers implementation-specific details such as persistence,
  # user interface, etc.
  class Post
    # Presentation-ish timestamp builder, used by `BylineBuilder`.
    module TimestampBuilder
      def self.timestamp_for(the_time = Time.now)
        the_time.to_time.localtime.strftime timestamp_format
      end

      def self.timestamp_format
        '%a %b %e %Y at %R %Z (%z)'
      end
    end # module Entity::Post::TimestampBuilder
  end # class Entity::Post
end
