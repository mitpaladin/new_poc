
require_relative 'bad_data_entity'

class UsersController < ApplicationController
  module Action
    # Encapsulates domain logic to update db record based on entity contents.
    class Update
      # Internal code called (initially) exclusively from Update class.
      module Internals
        # Update repository record based on entity contents/specified fields.
        class EntityRepoUpdater
          attr_reader :entity

          def initialize(current_user:, user_data:, user_repo_class: nil)
            @current_user = current_user
            @user_data = user_data
            @user_repo_class = user_repo_class || UserRepository
          end

          def update
            result = user_repo_class.new.update identifier: current_user.slug,
                                                updated_attrs: user_data
            @entity = result.entity
            return self if result.success?
            fail_with_bad_data
          end

          private

          attr_reader :current_user, :user_data, :user_repo_class

          def fail_with_bad_data
            data = BadDataEntity.new(data: data, current_user: current_user)
                   .data_from user_data
            fail JSON.dump data
          end
        end # class UsersController::...::Update::Internals::EntityRepoUpdater
      end
    end # class UsersController::Action::Update
  end
end # class UsersController
