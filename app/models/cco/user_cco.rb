
module CCO
  # CCO for Users. Does not (presently) subclass Base.
  class UserCCO
    def self.to_entity(impl, current_session = nil)
      wanted_attrs = impl.attributes.delete_if { |k, _v| k.match(/_at/) }
      wanted_attrs[:session_token] = _validate_session(current_session)
      User.new FancyOpenStruct.new(wanted_attrs)
    end

    def self.from_entity(entity)
      impl = UserData.new
      attrs = [:name, :email, :profile]
      attrs.each { |attr_name| impl[attr_name] = entity.send(attr_name) }
      impl
    end

    def self._validate_session(current_session)
      # FIXME: Need to actually validate incoming parameter!
      current_session
    end
  end # class CCO::UserCCO
end # module CCO
