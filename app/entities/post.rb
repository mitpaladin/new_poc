
require 'contracts'

require_relative 'post/attribute_container'
require_relative 'post/error_converter'
require_relative 'post/validator_grouping'

# Namespace containing all application-defined entities.
module Entity
  # The Post class encapsulates post-related domain logic of our "fancy" blog.
  # It delegates or defers implementation-specific details such as persistence,
  # user interface, etc.
  class Post
    extend Forwardable
    include Contracts

    def_delegator :@attributes, :attributes
    def_delegators :@validators, :valid?

    Contract RespondTo[:to_hash, :[]] => Post
    def initialize(attributes_in)
      init_attributes attributes_in
      define_attribute_readers
      @validators = ValidatorGrouping.new attributes_in
      self
    end

    # FIXME: Publication-attribute dependent Demeter violations
    Contract None => Bool
    def draft?
      !attributes.to_hash[:pubdate].present?
    end

    Contract None => Bool
    def published?
      !draft?
    end

    Contract None => String
    def pubdate_str
      return 'DRAFT' if draft?
      extend TimestampBuilder
      timestamp_for pubdate
    end

    # FIXME: Persistence-attribute dependent Demeter violation
    Contract None => Bool
    def persisted?
      attributes.to_hash[:slug].present?
    end

    Contract None => ActiveModel::Errors
    def errors
      ErrorConverter.new(@validators.errors).errors
    end

    Contract None => String
    def to_json
      attributes.to_hash.deep_symbolize_keys.tap do |r|
        r[:errors] = @validators.errors unless @validators.errors.empty?
      end.to_json
    end

    private

    Contract None => Entity::Post
    def define_attribute_readers
      attributes.to_hash.each_key do |key|
        class_eval { def_delegator :attributes, key }
      end
      self
    end

    Contract RespondTo[:to_hash, :[]] => Entity::Post
    def init_attributes(attributes_in)
      attrs = AttributeContainer.new attributes_in
      whitelist = [
        # core attributes
        :author_name, :body, :image_url, :title,
        # publication attributes
        :pubdate,
        # persistence attributes
        :created_at, :slug, :updated_at]
      @attributes = AttributeContainer.whitelist_from attrs, *whitelist
      self
    end
  end # class Entity::Post
end
