
require 'current_user_identity'

# Main application controller. Hang things off here that are needed by multiple
# controllers (which all subclass this one).
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def current_user=(new_user) # rubocop:disable Rails/Delegate
    identity.current_user = new_user
  end
  helper_method :current_user=

  def current_user # rubocop:disable Rails/Delegate
    identity.current_user
  end
  helper_method :current_user

  private

  def identity
    @identity ||= CurrentUserIdentity.new(session)
  end

  # Class method to define boilerplate controller actions.
  # @param action_sym [Symbol] Symbol for instance method to be defined,
  #                   e.g., :edit;
  #
  # The block will be evaluated in the context of the controller instance, so
  # methods like `#current_user` and instance values will Just Work.
  #
  # For a controller action #foo, you'd call this with the symbol :foo and a
  # block returning the parameters to be passed to Action::Foo.new. So your new
  # `#foo` method would instantiate the `Actions::Foo` class, call its Wisper
  # mixin `#subscribe` method with parameters of its instance and `:on_foo`,
  # which will be used as the prefix for the `:success` and `:failure`
  # notifications appropriate to the class, and then call the action instance's
  # `#execute` method.
  #
  def self.def_action(action_sym, &block)
    method_name = action_sym.downcase.to_s
    action_class = const_get(:Action).const_get method_name.capitalize.to_sym
    define_method method_name do
      action_class.new(instance_eval(&block))
        .subscribe(self, prefix: "on_#{method_name}".to_sym)
        .execute
    end
  end
end
