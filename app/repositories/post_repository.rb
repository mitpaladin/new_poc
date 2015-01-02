
require 'newpoc/repository/base'

# Intermediary between engine-bound DAO and Entity for Post-related use cases.
class PostRepository < Newpoc::Repository::Base
  def initialize(factory = PostFactory, dao = PostDao)
    super factory, dao
  end
end # class PostRepository
