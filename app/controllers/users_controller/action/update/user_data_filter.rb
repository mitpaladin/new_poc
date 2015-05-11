
require 'contracts'

class UsersController < ApplicationController
  module Action
    # Encapsulates domain logic to update db record based on entity contents.
    class Update
      # Filters out possible extraneous attributes passed in to Update class.
      class UserDataFilter
        include Contracts

        attr_reader :data

        Contract RespondTo[:to_hash] => UserDataFilter
        def initialize(user_data)
          @user_data = ActionSupport::Hasher.convert(user_data)
          self
        end

        Contract None => UserDataFilter
        def filter
          data = user_data.select { |k, _v| permitted_attribs.include? k }
          @data = FancyOpenStruct.new data
          self
        end

        private

        attr_reader :user_data

        Contract None => ArrayOf[Symbol]
        def permitted_attribs
          [:email, :profile, :password, :password_confirmation]
        end
      end # class UsersController::Action::Update::UserDataFilter
    end # class UsersController::Action::Update
  end
end # class UsersController
