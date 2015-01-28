
module Newpoc
  module Actions
    module Users
      # Wisper-based command object to return a collection of "user" objects.
      # Whatever they are.
      class Index
        include Wisper::Publisher

        def initialize(repository)
          @repository = repository
        end

        def execute
          broadcast_success repository.all
        end

        private

        attr_reader :repository

        def broadcast_success(payload)
          broadcast :success, payload
        end
      end # class Newpoc::Actions::Users::Index
    end
  end
end
