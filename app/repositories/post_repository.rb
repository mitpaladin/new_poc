
# Intermediary between engine-bound DAO and Entity for Post-related use cases.
class PostRepository
  def initialize(factory = PostFactory, dao = PostDao)
    @factory, @dao = factory, dao
  end

  def add(entity)
    record = dao.new entity.attributes
    return successful_result(record) if record.save
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
    StoreResult.new success: true, errors: nil,
                    entity: entity_if_record?(record)
  end
end # class PostRepository
