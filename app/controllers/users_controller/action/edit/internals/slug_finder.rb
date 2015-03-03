
# UsersController: actions related to Users within our "fancy" blog.
class UsersController < ApplicationController
  module Action
    # Edit-user domain-logic setup verifies that a user is logged in.
    class Edit
      # Internal support code for UsersController::Action::Edit class.
      module Internals
        # Search repository for record matching slug; return matching entity or
        # raise if no match found.
        class SlugFinder
          attr_reader :entity

          def initialize(slug:, repository:)
            @slug = slug
            @repository = repository
          end

          def find
            search_repository
            return self if result.success?
            raise_slug_not_found
          end

          private

          attr_reader :repository, :result, :slug

          def raise_slug_not_found
            error = { slug: slug.to_s }
            fail Yajl.dump(error)
          end

          def search_repository
            @result = repository.find_by_slug slug
            @entity = result.entity
          end
        end # class UsersController::Action::Edit::Internals::SlugFinder
      end
    end # class UsersController::Action::Edit
  end
end # class UsersController
