
# Intermediary between engine-bound DAO and Entity for User-related use cases.
class UserRepository < RepositoryBase
  def initialize(factory = UserFactory, dao = UserDao)
    super factory, dao
  end

  def authenticate(user, password)
    user_dao = dao.find_by_slug user.parameterize
    user = user_dao.authenticate password
    errors = ErrorFactory.create user_dao.errors
    entity = errors.empty? ? factory.create(user.attributes) : nil
    StoreResult.new entity: entity, errors: errors, success: errors.empty?
  end
end
