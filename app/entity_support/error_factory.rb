
# Another dirt-simple value class. Converts an Enumerable containing error
# field/message information to a JSON-friendly hash.
class ErrorFactory
  class << self
    def create(errors)
      errors.map do |error|
        { field: error[:field].to_s, message: error[:message] }
      end
    end
  end
end
