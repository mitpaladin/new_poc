
# Pundit authorisation policy for what would be SessionData record instances.
class SessionDataPolicy < ApplicationPolicy
  def create?
    # Should return `user.registered?` -- but that's an *entity* concept.
    user.name == user.class.first.name  # accept only the Guest User
  end

  def destroy?
    user.name != user.class.first.name  # reject the Guest User
  end

  def new?
    create?
  end
end # class SessionDataPolicy
