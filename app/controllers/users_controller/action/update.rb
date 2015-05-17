
require 'contracts'

require 'action_support/broadcaster'
require 'action_support/guest_user_access'

require_relative 'update/user_data_filter'

class UsersController < ApplicationController
  module Action
    # Encapsulates domain logic to update db record based on entity contents.
    class Update
      include ActionSupport::Broadcaster
      include Contracts

      attr_reader :entity

      INIT_CONTRACT_INPUTS = {
        current_user: RespondTo[:attributes, :name, :slug],
        user_data: Hash
      }

      Contract INIT_CONTRACT_INPUTS => Update
      def initialize(current_user:, user_data:)
        @current_user = current_user
        @user_data = UserDataFilter.new(user_data).filter.data
        self
      end

      Contract None => Update
      def execute
        prohibit_guest_access
        update_entity
        broadcast_success @entity
        self
      rescue RuntimeError => error
        broadcast_failure error.message
        self
      end

      private

      attr_reader :current_user, :user_data

      Contract None => Update
      def prohibit_guest_access
        ActionSupport::GuestUserAccess.new(current_user).prohibit
        self
      end

      Contract None => AlwaysRaises
      def update_entity
        result = UserRepository.new.update identifier: current_user.slug,
                                           updated_attrs: user_data
        @entity = result.entity
        return if result.errors.empty?
        ret = { messages: result.errors.full_messages }
        data = user_data.symbolize_keys
        ret[:entity] = current_user.attributes.symbolize_keys.merge data
        fail Yajl.dump(ret)
      end
    end # class UsersController::Action::Update
  end
end # class UsersController
