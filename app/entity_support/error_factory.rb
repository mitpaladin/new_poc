
# Another dirt-simple value class. Converts an Enumerable containing error
# field/message information to a JSON-friendly hash.
class ErrorFactory
  class << self
    def create(errors)
      errors.map do |field, message|
        { field: field.to_s, message: message }
      end
    end
  end
end
