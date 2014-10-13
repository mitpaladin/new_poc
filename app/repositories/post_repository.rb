
# Intermediary between engine-bound DAO and Entity for Post-related use cases.
class PostRepository < RepositoryBase
  def initialize(factory = PostFactory, dao = PostDao)
    super factory, dao
  end
end # class PostRepository
