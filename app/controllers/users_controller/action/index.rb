
require 'contracts'

require 'action_support/broadcaster'

# UsersController: actions related to Users within our "fancy" blog.
class UsersController < ApplicationController
  module Action
    # Broadcasts a list of all entries (here, Users) from a repository.
    class Index
      include ActionSupport::Broadcaster
      include Contracts

      Contract RespondTo[:all] => Index
      def initialize(repository)
        @repository = repository
        self
      end

      Contract None => Index
      def execute
        broadcast_success repository.all.sort
        self
      end

      private

      attr_reader :repository
    end # class UsersController::Action::Index
  end
end # class UsersController
