
require 'contracts'

# Identify/define "current", i.e., logged-in, user. This isn't just for
# controllers!
class CurrentUserIdentity
  include Contracts

  attr_reader :store, :user_class

  USER_CONTRACT = RespondTo[:slug]
  IDENT_CONTRACT = String

  Contract Hashlike, Class => CurrentUserIdentity
  def initialize(store, user_class = UserDao)
    @identifier = nil
    @store = store
    @user_class = user_class
    self
  end

  Contract None => Maybe[USER_CONTRACT]
  def current_user
    user_class.find identifier
  end

  Contract Maybe[USER_CONTRACT] => Any
  def current_user=(new_user)
    new_user ||= Naught.build.new   # call any method, get back nil
    send :identifier=, ident_for(new_user)
  end

  Contract None => Bool
  def guest_user?
    identifier == guest_user_identifier
  end

  Contract USER_CONTRACT => Maybe[IDENT_CONTRACT]
  def ident_for(user)
    user.slug
  end

  private

  Contract None => IDENT_CONTRACT
  def identifier
    store[:user_id] ||= guest_user_identifier
  end

  Contract Maybe[IDENT_CONTRACT] => IDENT_CONTRACT
  def identifier=(ident)
    store[:user_id] = validate_identifier(ident) || guest_user_identifier
  end

  Contract None => IDENT_CONTRACT
  def guest_user_identifier
    ident_for user_class.first
  end

  Contract Maybe[IDENT_CONTRACT] => Maybe[IDENT_CONTRACT]
  def validate_identifier(ident)
    ident_for(user_class.find ident)
  rescue # ActiveRecord::RecordNotFound
    nil
  end
end
