
require_relative 'create/new_entity_verifier'
require_relative 'create/password_verifier'
require_relative 'create/user_data_converter'
require 'action_support/broadcaster'
require 'action_support/entity_persister'
require 'action_support/guest_user_access'

# UsersController: actions related to Users within our "fancy" blog.
class UsersController < ApplicationController
  # Isolating our Action classes within the controller they're associate with.
  module Action
    # Wisper-based command object called by Users controller #new action.
    class Create
      include ActionSupport::Broadcaster
      include Contracts

      INIT_CONTRACT_INPUTS = {
        current_user: RespondTo[:name],
        user_data: Or[String, RespondTo[:to_hash]]
      }

      Contract INIT_CONTRACT_INPUTS => Create
      def initialize(current_user:, user_data:)
        @current_user = current_user
        @user_data = UserDataConverter.new(user_data).data
        @user_slug = @user_data[:slug] || @user_data[:name].parameterize
        @user_data.delete :slug # will be recreated on successful save
        @password = @user_data[:password]
        @password_confirmation = @user_data[:password_confirmation]
        self
      end

      Contract None => Create
      def execute
        require_guest_user
        verify_entity_does_not_exist
        verify_password
        add_user_entity_to_repo
        broadcast_success entity
        self
      rescue RuntimeError => error
        broadcast_failure error.message
        self
      end

      private

      attr_reader :current_user, :user_data, :entity

      Contract None => Create
      def verify_password
        PasswordVerifier.new(user_data).verify
        self
      end

      Contract None => Entity::User
      def add_user_entity_to_repo
        persister = ActionSupport::EntityPersister.new attributes: user_data,
                                                       repository: user_repo
        @entity = persister.persist do |attributes|
          password = attributes[:password]
          UserFactory::WithPassword.create(attributes, password).tap do |entity|
            entity.password = password
            entity.password_confirmation = password
          end
        end.entity
      end

      Contract None => Create
      def require_guest_user
        ActionSupport::GuestUserAccess.new(current_user).verify
        self
      end

      Contract None => Create
      def verify_entity_does_not_exist
        NewEntityVerifier.new(slug: @user_slug, attributes: user_data,
                              user_repo: user_repo).verify
        self
      end

      Contract None => UserRepository
      def user_repo
        @user_repo ||= UserRepository.new
      end
    end # class UsersController::Action::Create
  end # module UsersController::Action
end # class UsersController
