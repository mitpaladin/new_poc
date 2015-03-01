
module ActionSupport
  # Regularises Hashes and Rails' HashWithIndifferentAccess as used by actioms.
  class Hasher
    # Internal support methods for Hasher, since class methods can't be private.
    module Internals
      def self.convert_hash(data)
        data.send hasher_for(data)
      end

      def self.hasher_for(data)
        return :to_unsafe_h if data.respond_to? :to_unsafe_h
        :to_h
      end
    end
    private_constant :Internals

    def self.convert(data)
      Internals.convert_hash(data).symbolize_keys
    end
  end # class ActionSupport::Hasher
end
