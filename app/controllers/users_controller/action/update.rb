
require 'action_support/broadcaster'
require 'action_support/guest_user_access'

require_relative 'update/internals/bad_data_entity'
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

      def fail_with_bad_data(data)
        data = BadDataEntity.new(data: data, current_user: current_user)
               .data_from user_data
        fail JSON.dump data
      end

      def prohibit_guest_access
        ActionSupport::GuestUserAccess.new(current_user).prohibit
      end

      def update_entity
        # binding.pry user_data is empty at this point; why?
        result = user_repo.update identifier: current_user.slug,
                                  updated_attrs: user_data
        @entity = result.entity
        return if result.success?
        # Remember: @entity is `nil` at this point
        fail_with_bad_data user_data
      end

      def user_repo
        @user_repo ||= UserRepository.new
      end
    end # class UsersController::Action::Update
  end
end # class UsersController
