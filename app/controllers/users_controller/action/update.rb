
require 'action_support/broadcaster'
require 'action_support/guest_user_access'

require_relative 'update/internals/bad_data_entity'
require_relative 'update/internals/entity_repo_updater'
require_relative 'update/internals/user_data_filter'

class UsersController < ApplicationController
  module Action
    # Encapsulates domain logic to update db record based on entity contents.
    class Update
      # Internal code called (initially) exclusively from Update class.
      module Internals
      end
      private_constant :Internals
      include Internals
      include ActionSupport::Broadcaster

      attr_reader :entity

      def initialize(current_user:, user_data:)
        @current_user = current_user
        @user_data = UserDataFilter.new(user_data).filter.data
      end

      def execute
        prohibit_guest_access
        update_entity
        broadcast_success @entity
      rescue RuntimeError => error
        broadcast_failure error.message
      end

      private

      attr_reader :current_user, :user_data

      def prohibit_guest_access
        ActionSupport::GuestUserAccess.new(current_user).prohibit
      end

      def update_entity
        update_params = { current_user: current_user, user_data: user_data }
        @entity = EntityRepoUpdater.new(update_params).update.entity
      end
    end # class UsersController::Action::Update
  end
end # class UsersController
