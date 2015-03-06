
require 'current_user_identity'

# Main application controller. Hang things off here that are needed by multiple
# controllers (which all subclass this one).
class ApplicationController < ActionController::Base
  # Internal code used by ApplicationController, *not* directly by subclasses.
  module Internals
    def self.action_class_for(base_class, method_name)
      action_method = method_name.capitalize.to_sym
      base_class.const_get(:Action).const_get action_method
    end

    def self.listener_name_for(method_name)
      "on_#{method_name}".to_sym
    end

    def self.subscribe_params_for(method_name)
      { prefix: listener_name_for(method_name) }
    end
  end
  private_constant :Internals

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
    action_class = Internals.action_class_for self, method_name
    define_method method_name do
      action = action_class.new(instance_eval(&block))
      action.subscribe(self, Internals.subscribe_params_for(method_name))
        .execute
    end
  end
end
