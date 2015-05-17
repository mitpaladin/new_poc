
require 'contracts'

# UsersController: actions related to Users within our "fancy" blog.
class UsersController < ApplicationController
  # Isolating our Action classes within the controller they're associate with.
  module Action
    # Wisper-based command object called by Users controller #new action.
    class Create
      # Convert a query-string-formatted Hash of user data first into a Hash
      # and then replace each array holding a value with that value.
      # This very well may be more general-purpose than just this action...
      class UserDataConverter
        include Contracts

        attr_reader :data

        Contract Or[String, RespondTo[:to_hash]] => UserDataConverter
        def initialize(input)
          @data = parse input
          self
        end

        private

        # CGI.parse will *always* return key/value pairs using *arrays* of
        # values, even when there is only one. This understandably FUBARs code
        # expecting simple key/value pairs.
        Contract String => HashOf[Symbol, Any]
        def data_from(input)
          data = CGI.parse input
          data.each { |k, v| data[k] = v.first }.symbolize_keys
        end

        Contract Or[String, RespondTo[:to_hash]] => FancyOpenStruct
        def parse(input)
          case input
          when String
            FancyOpenStruct.new data_from(input)
          else # Hash or OpenStruct
            FancyOpenStruct.new input
          end
        end
      end # class UsersController::Action::Create::UserDataConverter
    end # class UsersController::Action::Create
  end
end # class UsersController
