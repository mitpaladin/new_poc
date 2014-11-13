
module ApplicationHelper
  # Module containing the `#build_greeter_for` application-helper method.
  module BuildGreeterFor
    class UserParameterHasNoName < StandardError
    end

    def build_greeter_for(user)
      fail UserParameterHasNoName unless user.respond_to?(:name)

      classes = 'greeter navbar-text navbar-right'
      content_tag :div, nil, { class: classes }, false do
        concat "Hello, #{user.name}!"
      end
    end
  end # module ApplicationHelper::BuildGreeterFor
end # module ApplicationHelper
