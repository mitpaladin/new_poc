
module Newpoc
  module Support
    # This is a dirt-simple little value object that gets kicked around to
    # isolate the underlying database implementation (ActiveRecord, Sequel or
    # whatever) from Other Stuff like DM repos and use cases.
    class StoreResult
      attr_reader :entity, :errors, :success
      alias_method :success?, :success

      def initialize(entity:, success:, errors:)
        @entity, @success, @errors = entity, success, errors
      end
    end # class Newpoc::Support::StoreResult
  end
end # module Newpoc
