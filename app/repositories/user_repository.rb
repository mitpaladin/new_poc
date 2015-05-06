
require 'repository/base'
require 'repository/support/store_result'

# Intermediary between engine-bound DAO and Entity for User-related use cases.
class UserRepository < Repository::Base
  def initialize(factory = UserFactory, dao = UserDao)
    super factory: factory, dao: dao
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
    entity = UserFactory.create(user) if errors.empty?
    Repository::Support::StoreResult.new entity: entity,
                                         errors: errors,
                                         success: errors.empty?
  end

  def guest_user
    user_dao = dao.first
    errors = Repository::Support::ErrorFactory.create(user_dao.errors)
    new_entity = factory.create(user_dao.attributes.symbolize_keys)
    Repository::Support::StoreResult.new entity: new_entity,
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
    return guest_user.entity unless user
    factory.create user.attributes
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
    Repository::Support::ErrorFactory.create data
  end

  def return_for_invalid_user
    errors = invalid_user_name_or_password
    Repository::Support::StoreResult.new entity: guest_user.entity,
                                         errors: errors,
                                         success: false
  end

  def test_environment?
    Rails.env.test?
  end
end
