
require 'contracts'

# UsersController: actions related to Users within our "fancy" blog.
class UsersController < ApplicationController
  # Isolating our Action classes within the controller they're associate with.
  module Action
    # Wisper-based command object called by Users controller #new action.
    class Create
      # Verify identified entity does not exist; raise error if it does.
      class NewEntityVerifier
        include Contracts

        INIT_CONTRACT_INPUTS = {
          slug: String,
          attributes: RespondTo[:to_hash],
          user_repo: RespondTo[:find_by_slug]
        }

        Contract INIT_CONTRACT_INPUTS => NewEntityVerifier
        def initialize(slug:, attributes:, user_repo:)
          @slug = slug
          @attributes = attributes
          @user_repo = user_repo
          self
        end

        Contract None => nil
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
