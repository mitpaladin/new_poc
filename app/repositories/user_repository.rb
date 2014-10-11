
# Intermediary between engine-bound DAO and Entity for User-related use cases.
class UserRepository
  def initialize(factory = UserFactory, dao = UserDao)
    @factory, @dao = factory, dao
  end

  def add(entity)
    record = dao.new entity.attributes
    return successful_result(record) if record.save
    failed_result_with_errors record.errors
  end

  def find_by_slug(slug)
    dao.where(slug: slug).first
  end

  def update(entity)
    record = find_by_slug entity.slug
    if record && record.update_attributes(entity.attributes)
      return successful_result(record)
    end

    return failed_result_with_errors(record.errors) if record
    failed_result entity.slug
  end

  private

  attr_reader :dao, :factory

  def entity_if_record?(record)
    return nil unless record
    factory.create record
  end

  def successful_result(record)
    StoreResult.new success: true, errors: nil,
                    entity: entity_if_record?(record)
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
end
