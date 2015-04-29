
require 'repository/base'

# This is needed because Rails' autoloading doesn't like two classes with the
# same base name, even when they're in different namespaces. Boo, hiss.
require_relative '../entities/post'

# Namespace containing all Repository classes: intermediaries between DAOs and
# Entities.
module Repository
  # Intermediary between engine-bound DAO and Entity for Post-related use cases.
  class Post < Base
    def initialize(factory = PostFactory, dao = PostDao)
      super factory: factory, dao: dao
    end
  end
end
