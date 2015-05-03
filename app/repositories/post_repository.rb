
require 'repository/base'

# Intermediary between engine-bound DAO and Entity for Post-related use cases.
class PostRepository < Repository::Base
  def initialize(factory = PostFactory, dao = PostDao)
    super factory: factory, dao: dao
  end
end # class PostRepository
