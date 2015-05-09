
require_relative 'entity_exists_failure'

# UsersController: actions related to Users within our "fancy" blog.
class UsersController < ApplicationController
  # Isolating our Action classes within the controller they're associate with.
  module Action
    # Wisper-based command object called by Users controller #new action.
    class Create
      # Verify identified entity does not exist; raise error if it does.
      class NewEntityVerifier
        def initialize(slug:, attributes:, user_repo:)
          @slug = slug
          @attributes = attributes
          @user_repo = user_repo
        end

        def verify
          return unless user_repo.find_by_slug(slug).success?
          EntityExistsFailure.new(attributes: attributes, slug: slug).fail
        end

        private

        attr_reader :attributes, :slug, :user_repo
      end # class UsersController::Action::Create::NewEntityVerifier
    end # class UsersController::Action::Create
  end
end # class UsersController
