
# UsersController: actions related to Users within our "fancy" blog.
class UsersController < ApplicationController
  # include Internals

  # Isolating our Action classes within the controller they're associate with.
  module Action
    # Wisper-based command object called by Users controller #new action.
    class Create
      module Internals
        # Build and raise a RuntimeError with YAML-encoded data as message.
        class DataObjectFailure
          def initialize(options)
            @data = build_data_from_options options
          end

          def fail
            Kernel.fail YAML.dump(data)
          end

          private

          attr_reader :data

          def build_data_from_options(options = {})
            messages = options.fetch :messages, []
            attributes = options.fetch :attributes, nil
            data = { messages: messages }
            data[:attributes] = attributes if attributes
            data
          end
        end # class UsersController::Action::...::Internals::DataObjectFailure
      end
    end # class UsersController::Action::Create
  end
end # class UsersController
