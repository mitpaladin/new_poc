
require 'action_support/hasher'

class UsersController < ApplicationController
  module Action
    # Encapsulates domain logic to update db record based on entity contents.
    class Update
      # Filters out possible extraneous attributes passed in to Update class.
      class UserDataFilter
        attr_reader :data

        def initialize(user_data)
          @user_data = ActionSupport::Hasher.convert(user_data)
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
      end # class UsersController::Action::Update::UserDataFilter
    end # class UsersController::Action::Update
  end
end # class UsersController
