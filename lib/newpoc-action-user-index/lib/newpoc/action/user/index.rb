
require 'fancy-open-struct'
require 'wisper'

require 'newpoc/action/user/index/version'

module Newpoc
  module Action
    module User
      # Domain action broadcasts a list of all Users from a repository.
      class Index
        include Wisper::Publisher

        def initialize(repository, success_event = :success)
          @repository = repository
          @success_event = success_event
        end

        # Failure is not an option.
        def execute
          broadcast_success repository.all
        end

        private

        attr_reader :repository, :success_event

        def broadcast_success(payload)
          broadcast success_event, payload
        end
      end # class Newpoc::Action::User::Index
    end
  end
end
