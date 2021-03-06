
require 'contracts'

module ActionSupport
  # Regularises Hashes and Rails' HashWithIndifferentAccess as used by actioms.
  class Hasher
    include Contracts

    # Internal support methods for Hasher, since class methods can't be private.
    module Internals
      include Contracts

      DATA_CONTRACT = Or[RespondTo[:to_unsafe_h], RespondTo[:to_hash]]

      Contract DATA_CONTRACT => RespondTo[:symbolize_keys]
      def self.convert_hash(data)
        data.send hasher_for(data)
      end

      Contract DATA_CONTRACT => Symbol
      def self.hasher_for(data)
        return :to_unsafe_h if data.respond_to? :to_unsafe_h
        :to_h
      end
    end
    private_constant :Internals

    Contract Internals::DATA_CONTRACT => Hashlike
    def self.convert(data)
      Internals.convert_hash(data).symbolize_keys
    end
  end # class ActionSupport::Hasher
end
