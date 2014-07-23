
# Dummy model class for SessionDataPolicy.
class SessionData
  # include ActiveAttr::BasicModel
  include ActiveAttr::TypecastedAttributes
  include ActiveAttr::MassAssignment

  attribute :id, type: Integer
  attr_accessor :id

  def exists?
    false
  end

  def self.where(*)
    SessionData.new
  end
end # class SessionData
