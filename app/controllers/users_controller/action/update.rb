
require 'action_support/broadcaster'
require 'action_support/guest_user_access'

class UsersController < ApplicationController
  module Action
    # Encapsulates domain logic to update db record based on entity contents.
    class Update
      module Internals
        # Filters out possible extraneous attributes passed in to Update class.
        class UserDataFilter
          attr_reader :data

          def initialize(user_data)
            @user_data = hash_input_data user_data
          end

          def filter
            data = user_data.select do |attrib, _v|
              permitted_attribs.include? attrib
            end
            @data = FancyOpenStruct.new data
            self
          end

          private

          attr_reader :user_data

          def permitted_attribs
            [:email, :profile, :password, :password_confirmation]
          end

          # NOTE: Next 2 methods dupe existing methods of same names in
          # PostsController::Action::Create::Internals::PostDataFilter.
          def hash_input_data(data)
            data.send(hasher_for(data)).symbolize_keys
          end

          def hasher_for(data)
            return :to_unsafe_h if data.respond_to? :to_unsafe_h
            :to_h
          end
        end # class UsersController::Action::Update::Internals::UserDataFilter

        # Support class for #fail_with_bad_data
        class BadDataEntity
          def initialize(data:, current_user:)
            attribs = current_user.attributes.reject { |s| s.match(/password/) }
            @entity = Newpoc::Entity::User.new attribs.merge(data)
            @entity.invalid?
          end

          def data_from(user_data)
            check_password_mismatch user_data
            build_data
          end

          private

          attr_reader :entity

          def build_data
            {
              messages: entity.errors.full_messages,
              entity: entity_without_errors
            }
          end

          def entity_without_errors
            entity.attributes.reject { |k, _| k == :errors }
          end

          def check_password_mismatch(user_data)
            return if user_data.password == user_data.password_confirmation
            message = 'Password must match the password confirmation'
            entity.errors.add :base, message
          end
        end
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
