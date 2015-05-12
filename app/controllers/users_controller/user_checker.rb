
require 'contracts'

# Internal classes used by our UsersController.
class UsersController < ApplicationController
  # Contains internal modules/classes used by #on_create_failure.
  module CreateFailure
    # A #valid? user is invalid, because it's been kicked back to us with a
    # conflicting name.
    class UserChecker
      include Contracts

      Contract String, Any => UserChecker
      def initialize(payload, controller)
        @controller = controller
        @data = FancyOpenStruct.new YAML.load(payload)
        self
      end

      Contract None => Maybe[Entity::User]
      def parse
        attributes = data[:attributes]
        @user = create_user_entity(attributes) if attributes
        record_invalid_password_errors
        record_existing_name_errors
        record_other_name_issues
        user
      end

      private

      Contract RespondTo[:to_hash] => Entity::User
      def create_user_entity(attributes)
        UserFactory.create attributes
      end

      Contract Symbol, Regexp => UserChecker
      def record_any_invalid_items_for(item_key, pattern)
        @filtered_messages = data[:messages].grep pattern
        return self if filtered_messages.empty?
        filtered_messages.each do |message|
          user.errors.add item_key, message_text_with_leader(message)
        end
        self
      end

      Contract None => UserChecker
      def record_invalid_password_errors
        record_any_invalid_items_for(:password, /Password/)
      end

      Contract None => UserChecker
      def record_existing_name_errors
        record_any_invalid_items_for(:name, /already exists/)
      end

      Contract None => UserChecker
      def record_other_name_issues
        record_any_invalid_items_for(:name, /Name/)
      end

      Contract String => String
      def message_text_with_leader(message_text)
        'is invalid: ' + message_text
      end

      attr_reader :controller, :data, :user, :filtered_messages
    end # class UsersController::CreateFailure::UserChecker
  end # module UsersController::CreateFailure
end # class UsersController
