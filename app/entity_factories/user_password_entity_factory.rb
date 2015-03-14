
require_relative 'user_factory'

# Class to create instance of entities with passwords for use cases.
class UserPasswordEntityFactory
  def self.create(attribs_in, password)
    entity = UserFactory.create attribs_in
    entity.class.class_eval do
      attr_accessor :password
      attr_accessor :password_confirmation
    end
    entity.password = password
    entity.password_confirmation = password
    entity
  end
end
