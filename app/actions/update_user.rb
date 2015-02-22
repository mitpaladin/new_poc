
module Actions
  # Wisper-based command object called by Users controller #update action.
  class UpdateUser
    include Wisper::Publisher

    def initialize(user_data, current_user)
      @user_data = filter_user_data(user_data)
      @current_user = current_user
    end

    def execute
      prohibit_guest_access
      update_entity
      broadcast_success @entity
    rescue RuntimeError => error
      broadcast_failure error.message
    end

    private

    attr_reader :user_data, :current_user

    # Support methods

    # ... for #initialize

    def filter_user_data(user_data)
      data = user_data.symbolize_keys.select do |attrib, _value|
        permitted_attribs.include? attrib
      end
      FancyOpenStruct.new data
    end

    # ... for #execute

    def broadcast_failure(payload)
      broadcast :failure, payload
    end

    def broadcast_success(payload)
      broadcast :success, payload
    end

    def prohibit_guest_access
      return unless guest_user.name == current_user.name
      fail_with_messages guest_user_not_authorised_message
    end

    def update_entity
      result = user_repo.update identifier: current_user.slug,
                                updated_attrs: user_data
      @entity = result.entity
      return if result.success?
      # Remember: @entity is `nil` at this point
      fail_with_bad_data user_data
    end

    def guest_user
      user_repo.guest_user.entity
    end

    def guest_user_not_authorised_message
      'Not logged in as a registered user!'
    end

    def user_repo
      @user_repo ||= UserRepository.new
    end

    def permitted_attribs
      [:email, :profile, :password, :password_confirmation]
    end

    # ... for #update_entity

    # Support class for #fail_with_bad_data
    class BadDataEntity
      def initialize(data, current_user)
        attribs = current_user.attributes.reject { |s| s.match(/password/) }
        @entity = Newpoc::Entity::User.new attribs.merge(data)
        @entity.invalid?
      end

      def data_from(user_data)
        check_password_mismatch user_data
        build_data
      end

      private

      attr_reader :entity

      def build_data
        {
          messages: entity.errors.full_messages,
          entity: entity_without_errors
        }
      end

      def entity_without_errors
        entity.attributes.reject { |k, _| k == :errors }
      end

      def check_password_mismatch(user_data)
        return if user_data.password == user_data.password_confirmation
        entity.errors.add :base, 'Password must match the password confirmation'
        # message = { base: 'Password must match the password confirmation' }
        # msg = Repository::Support::ErrorFactory.create message
        # entity.errors[:messages] = msg
      end
    end
    private_constant :BadDataEntity

    def fail_with_bad_data(data)
      data = BadDataEntity.new(data, current_user).data_from user_data
      fail JSON.dump data
    end

    def fail_with_messages(messages)
      fail JSON.dump(messages: Array(messages))
    end
  end # class Actions::UpdateUser
end # module Actions
