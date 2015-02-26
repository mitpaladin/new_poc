
require_relative 'create/internals/entity_persister'
require_relative 'create/internals/guest_user_verifier'
require_relative 'create/internals/new_entity_verifier'
require_relative 'create/internals/password_verifier'
require_relative 'create/internals/user_data_converter'
require 'broadcaster'

# UsersController: actions related to Users within our "fancy" blog.
class UsersController < ApplicationController
  # Isolating our Action classes within the controller they're associate with.
  module Action
    # Wisper-based command object called by Users controller #new action.
    class Create
      # Internal code called (initially) exclusively from Create class.
      module Internals
      end
      private_constant :Internals
      include Internals
      include Broadcaster

      def initialize(current_user:, user_data:)
        @current_user = current_user
        @user_data = UserDataConverter.new(user_data).data
        @user_slug = @user_data[:slug] || @user_data[:name].parameterize
        @user_data.delete :slug # will be recreated on successful save
        @password = @user_data[:password]
        @password_confirmation = @user_data[:password_confirmation]
      end

      def execute
        require_guest_user
        verify_entity_does_not_exist
        verify_password
        add_user_entity_to_repo
        broadcast_success entity
      rescue RuntimeError => error
        broadcast_failure error.message
      end

      private

      attr_reader :current_user, :user_data, :entity

      def verify_password
        PasswordVerifier.new(user_data).verify
      end

      def add_user_entity_to_repo
        persister = EntityPersister.new attributes: user_data,
                                        repository: user_repo
        @entity = persister.persist.entity
      end

      def require_guest_user
        GuestUserVerifier.new(current_user).verify
      end

      def verify_entity_does_not_exist
        NewEntityVerifier.new(slug: @user_slug, attributes: user_data,
                              user_repo: user_repo).verify
      end

      # Support methods

      def user_repo
        @user_repo ||= UserRepository.new
      end
    end # class UsersController::Action::Create
  end # module UsersController::Action
end # class UsersController
