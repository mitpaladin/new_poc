
# Namespace containing all application-defined entities.
module Entity
  # The `User` class is the *core business-logic entity* modelling users in the
  # system. The core class encapsulates logic not specific to one use case or
  # group of use cases (such as authorisation). It also establishes a namespace
  # which encapsulates more specific entity-oriented responsibilities.
  class User
    # The `GuestUser` class represents a `User` that is not logged in; i.e., it
    # implements a null object or default current user.
    class GuestUser < User
      # Creates a GuestUser instance, having a fixed name and invalid state.
      def initialize
        profile = 'No user is presently logged in. I was *never* here.'
        super name: self.class.guest_user_name, profile: profile
      end

      def self.guest_user_name
        'Guest User'
      end
    end # class Entity::User::GuestUser
    private_constant :GuestUser

    # The `.guest_user` class method returns an instance of the GuestUser class.
    # Note that this is *not* an instance method on `Entity::User`.
    # @return Guest User instance; User entity with dummied values and an
    #         invalid, unpersisted, unpersistable state.
    def self.guest_user
      GuestUser.new
    end

    # The `#guest_user?` method queries if an instance is the Guest User.
    # @return boolean Returns true for the Guest User; false otherwise.
    def guest_user?
      name == GuestUser.guest_user_name
    end
  end # class Entity::User
end
