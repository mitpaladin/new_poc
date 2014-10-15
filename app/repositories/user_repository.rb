
# Intermediary between engine-bound DAO and Entity for User-related use cases.
class UserRepository < RepositoryBase
  def initialize(factory = UserFactory, dao = UserDao)
    super factory, dao
  end

  # Don't return the Guest User as part of the results from #all.
  def all
    super.reject { |user| user.slug == 'guest-user' }
  end

  def authenticate(user, password)
    user_dao = dao.find_by_slug user.parameterize
    return return_for_invalid_user unless user_dao

    user = user_dao.authenticate password
    errors = errors_for user
    StoreResult.new entity: entity_for(user),
                    errors: errors,
                    success: errors.empty?
  end

  def guest_user
    user_dao = dao.first
    errors = ErrorFactory.create(user_dao.errors)
    StoreResult.new entity: factory.create(user_dao.attributes),
                    errors: errors,
                    success: errors.empty?
  end

  private

  def entity_for(user)
    return factory.create(user.attributes) if user
    guest_user.entity
  end

  def errors_for(user)
    return [] if user
    invalid_user_name_or_password
  end

  def invalid_user_name_or_password
    data = { base: 'Invalid user name or password' }
    ErrorFactory.create data
  end

  def return_for_invalid_user
    StoreResult.new entity: guest_user.entity,
                    errors: invalid_user_name_or_password,
                    success: false
  end
end
