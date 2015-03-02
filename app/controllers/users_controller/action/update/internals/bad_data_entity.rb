
class UsersController < ApplicationController
  module Action
    # Encapsulates domain logic to update db record based on entity contents.
    class Update
      module Internals
        # Support class for EntityRepoUpdater
        class BadDataEntity
          def initialize(data:, current_user:)
            attribs = current_user.attributes.reject { |s| s.match(/password/) }
            @entity = Newpoc::Entity::User.new attribs.to_h.merge(data.to_h)
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
        end # class UsersController::Action::Update::Internals::BadDataEntity
      end
    end # class UsersController::Action::Update
  end
end # class UsersController
