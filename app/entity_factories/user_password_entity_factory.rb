
require_relative 'user_factory'

# Class to create instance of entities with passwords for use cases.
class UserPasswordEntityFactory
  def self.create(attribs_in, password)
    entity = UserFactory.create attribs_in
    entity.add_attribute :password, password
    entity.add_attribute :password_confirmation, password
    # Password entities aren't like usual entities; need to be assignable.
    entity.class_eval { attr_writer :password, :password_confirmation }
    entity
  end
end
