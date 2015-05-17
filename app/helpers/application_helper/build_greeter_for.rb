
require 'contracts'

module ApplicationHelper
  # Module containing the `#build_greeter_for` application-helper method.
  module BuildGreeterFor
    include Contracts

    Contract RespondTo[:name] => String
    def build_greeter_for(user)
      classes = 'greeter navbar-text navbar-right'
      content_tag :div, nil, { class: classes }, false do
        concat "Hello, #{user.name}!"
      end
    end
  end # module ApplicationHelper::BuildGreeterFor
end # module ApplicationHelper
