
# Intermediary between engine-bound DAO and Entity for User-related use cases.
class UserRepository < RepositoryBase
  def initialize(factory = UserFactory, dao = UserDao)
    super factory, dao
  end
end
