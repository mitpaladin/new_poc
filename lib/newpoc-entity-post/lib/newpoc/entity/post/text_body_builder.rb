
module Newpoc
  module Entity
    # a Post is the domain entity for a blog-type post, with title, body, etc.
    class Post
      module SupportClasses
        # Build text post body.
        class TextBodyBuilder
          def build(obj)
            "\n#{obj.body}\n"
          end
        end # class Newpoc::Entity::Post::SupportClasses::TextBodyBuilder
      end # module Newpoc::Entity::Post::SupportClasses
    end # class Newpoc::Entity::Post
  end # module Newpoc::Entity
end # module Newpoc
