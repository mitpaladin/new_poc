
require_relative 'user_factory'

# Class to create instance of entities with passwords for use cases.
class UserPasswordEntityFactory
  def self.create(attribs_in, password)
    entity = UserFactory.create attribs_in
    entity.add_attribute :password, password
    entity.add_attribute :password_confirmation, password
    entity
  end
end
