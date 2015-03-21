
# Namespace containing all application-defined entities.
module Entity
  # The Post class encapsulates post-related domain logic of our "fancy" blog.
  # It delegates or defers implementation-specific details such as persistence,
  # user interface, etc.
  class Post
    attr_reader :author_name, :title

    def initialize(attributes)
      @title = attributes[:title].to_s
      @author_name = attributes[:author_name].to_s
    end
  end # class Entity::Post
end
