
require 'newpoc/support/store_result'
require 'newpoc/repository/internal/error_factory'

module Newpoc
  module Repository
    # Base class of all Repository classes for app.
    class Base
      attr_reader :dao, :factory

      def initialize(factory, dao)
        @factory, @dao = factory, dao
      end

      def add(entity)
        attribs = entity.attributes.reject { |k, _v| k == :errors }
        record = dao.new attribs
        record_saved = record.save
        return successful_result(record) if record_saved
        failed_result_with_errors record.errors
      end

      def all
        dao.all.map { |record| factory.create record }
      end

      def find_by_slug(slug)
        found_post = dao.where(slug: slug).first
        return successful_result(found_post) if found_post
        fail_with_slug_not_found slug
      end

      def update(identifier, updated_attrs)
        record = dao.where(slug: identifier).first
        success = record.update_attributes(updated_attrs.to_h)
        return successful_result(record) if success
        failed_result_with_errors record.errors
      end

      private

      def fail_with_slug_not_found(slug)
        errors = ActiveModel::Errors.new dao
        errors.add :base, "A record with 'slug'=#{slug} was not found."
        failed_result_with_errors errors
      end

      def failed_result_with_errors(errors_in)
        errors = Newpoc::Repository::Internal::ErrorFactory.create errors_in
        Newpoc::Support::StoreResult.new entity: nil, success: false,
                                         errors: errors
      end

      def successful_result(record)
        Newpoc::Support::StoreResult.new success: true, errors: [],
                                         entity: factory.create(record)
      end
    end # class Newpoc::Repository::Base
  end # module Newpoc::Repository
end # module Newpoc
