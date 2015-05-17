
require 'contracts'

# Supporting code used by and for controller-namespaced Action classes.
module ActionSupport
  # Search repository for record matching slug; return matching entity or
  # raise if no match found.
  class SlugFinder
    include Contracts

    attr_reader :entity

    INIT_CONTRACT_INPUTS = {
      slug: String,
      repository: RespondTo[:find_by_slug]
    }

    Contract INIT_CONTRACT_INPUTS => SlugFinder
    def initialize(slug:, repository:)
      @slug = slug
      @repository = repository
      self
    end

    Contract None => SlugFinder
    def find
      search_repository
      return self if result.success?
      raise_slug_not_found
    end

    private

    attr_reader :repository, :result, :slug

    Contract None => AlwaysRaises
    def raise_slug_not_found
      error = { slug: slug.to_s }
      fail Yajl.dump(error)
    end

    Contract None => Maybe[RespondTo[:slug]]
    def search_repository
      @result = repository.find_by_slug slug
      @entity = result.entity
    end
  end # class ActionSupport::SlugFinder
end # module ActionSupport
