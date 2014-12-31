
require 'meldd_repository/repository_base'
require 'meldd_repository/store_result'

# Intermediary between engine-bound DAO and Entity for User-related use cases.
class UserRepository < MelddRepository::RepositoryBase
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
    MelddRepository::StoreResult.new entity: entity_for(user),
                                     errors: errors,
                                     success: errors.empty?
  end

  def guest_user(*options)
    user_dao = dao.first
    errors = ErrorFactory.create(user_dao.errors)
    entity = factory.create(attributes_for user_dao, options)
    MelddRepository::StoreResult.new entity: entity,
                                     errors: errors,
                                     success: errors.empty?
  end

  private

  def attributes_for(user_dao, options)
    attribs = OpenStruct.new user_dao.attributes
    # set dummy password for testing
    if test_environment? && include_password?(options)
      attribs.password = 'password'
      attribs.password_confirmation = attribs.password
    end
    attribs
  end

  def entity_for(user)
    return factory.create(user.attributes) if user
    guest_user.entity
  end

  def errors_for(user)
    return [] if user
    invalid_user_name_or_password
  end

  def include_password?(options)
    !options.include?(:no_password)
  end

  def invalid_user_name_or_password
    data = { base: 'Invalid user name or password' }
    ErrorFactory.create data
  end

  def return_for_invalid_user
    errors = invalid_user_name_or_password
    MelddRepository::StoreResult.new entity: guest_user.entity,
                                     errors: errors,
                                     success: false
  end

  def test_environment?
    Rails.env.test?
  end
end
