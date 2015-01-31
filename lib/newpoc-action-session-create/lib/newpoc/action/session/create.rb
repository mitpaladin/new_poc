
require 'active_support/core_ext/string/inflections'
require 'wisper'

require 'newpoc/action/session/create/version'

module Newpoc
  module Action
    module Session
      # Domain/business-logic action for authenticating a user.
      class Create
        include Wisper::Publisher

        def initialize(user_name, password, user_repository)
          @user_name = user_name
          @password = password
          @user_repository = user_repository
        end

        def execute
          authenticate_user
          broadcast_success @entity
        rescue RuntimeError => error
          broadcast_failure error.message
        end

        private

        attr_reader :password, :user_name, :user_repository

        def authenticate_user
          auth_params = [user_name.to_s.parameterize, password]
          result = user_repository.authenticate(*auth_params)
          @entity = result.entity
          return if result.success?
          fail result.errors.first[:message]
        end

        def broadcast_failure(payload)
          broadcast :failure, payload
        end

        def broadcast_success(payload)
          broadcast :success, payload
        end
      end # class Newpoc::Action::Session::Create
    end
  end
end
