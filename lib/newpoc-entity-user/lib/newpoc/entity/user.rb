
require 'newpoc/entity/user/version'

module Newpoc
  module Entity
    # Domain entity for a user of the system.
    class User
      attr_reader :email,
                  :name,
                  :profile,
                  :slug,
                  :created_at,
                  :updated_at

      def initialize(attribs)
        @name = attribs[:name]
        @email = attribs[:email]
        @slug = attribs[:slug]
        @updated_at = attribs[:updated_at]
        @profile = attribs.fetch :profile, ''
        @created_at = attribs.fetch :created_at, Time.now
      end

      def attributes
        {
          email: email,
          name: name,
          profile: profile,
          slug: slug,
          created_at: created_at,
          updated_at: updated_at
        }
      end

      def [](key)
        attributes[key]
      end
    end # class Newpoc::Entity::User
  end
end
