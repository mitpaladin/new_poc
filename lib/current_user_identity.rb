
# Identify/define "current", i.e., logged-in, user. This isn't just for
# controllers!
class CurrentUserIdentity
  attr_reader :store, :user_class

  def initialize(store, user_class = UserDao)
    @identifier = nil
    @store = store
    @user_class = user_class
  end

  def current_user
    user_class.find identifier
  end

  def current_user=(new_user)
    new_user ||= Naught.build.new   # call any method, get back nil
    send :identifier=, ident_for(new_user)
  end

  def guest_user?
    identifier == guest_user_identifier
  end

  def ident_for(user)
    user.slug
  end

  private

  def identifier
    store[:user_id] ||= guest_user_identifier
  end

  def identifier=(ident)
    store[:user_id] = validate_identifier(ident) || guest_user_identifier
  end

  def guest_user_identifier
    ident_for user_class.first
  end

  def validate_identifier(ident)
    ident_for(user_class.find ident)
  rescue ActiveRecord::RecordNotFound
    nil
  end
end
