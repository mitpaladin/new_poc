
# Shared code for mediating between engine-bound DAO and Entity for use cases.
class RepositoryBase
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

  # def delete(slug)
  #   # We pass in a slug; the Repository (and Entity) don't know what an 'id'
  #   # is. The DAO, however, is ActiveRecord, and seems to need an ID
  #   record = dao.find_by_slug(slug)
  #   return failed_result(slug) unless record
  #   destroyed_record_count = dao.delete(record.id)
  #   # This should never happen; if we can see it, we can delete it
  #   return failed_result(record.id) if destroyed_record_count.zero?
  #   successful_result
  # end

  def find_by_slug(slug)
    found_post = dao.where(slug: slug).first
    return successful_result(found_post) if found_post
    failed_result slug
  end

  def update(identifier, updated_attrs)
    record = dao.where(slug: identifier).first
    success = record.update_attributes(updated_attrs.to_h)
    return successful_result(record) if success
    failed_result_with_errors record.errors
  end

  private

  attr_reader :dao, :factory

  def entity_if_record?(record)
    return nil unless record
    factory.create record
  end

  def failed_result_with_errors(errors)
    StoreResult.new entity: nil, success: false,
                    errors: ErrorFactory.create(errors)
  end

  def failed_result(slug)
    errors = ActiveModel::Errors.new dao
    errors.add :base, "A record with 'slug'=#{slug} was not found."
    failed_result_with_errors errors
  end

  def successful_result(record = nil)
    StoreResult.new success: true, errors: ErrorFactory.create([]),
                    entity: entity_if_record?(record)
  end
end # class RepositoryBase
