
require 'newpoc/services/markdown_html_converter'

# Namespace containing all application-defined entities.
module Entity
  # The `User` class is the *core business-logic entity* modelling users in the
  # system. The core class encapsulates logic not specific to one use case or
  # group of use cases (such as authorisation). It also establishes a namespace
  # which encapsulates more specific entity-oriented responsibilities.
  class User
    # Adds the `#formatted_profile` method and its supporting attribute to an
    # object instance (presumably of `Entity::User`).
    class ProfileFormatterSetup
      # Internal code used exclusively by `ProfileFormatterSetup`.
      module Internals
        # Gets the lambda to call to convert Markdown to HTML, with a default.
        # @param attributes [Hash] May contain injected :markdown_converter item
        # @return [lambda] Callable lambda/block taking one parameter.
        def get_markdown_converter(attributes)
          key = :markdown_converter
          return attributes[key] if attributes[key].respond_to? :call
          lambda do |markup|
            Newpoc::Services::MarkdownHtmlConverter.new.to_html markup
          end
        end
      end
    end # class Entity::User::ProfileFormatterSetup
  end # class Entity::User
end
