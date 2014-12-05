
module Actions
  # Wisper-based command object called by Users controller #new action.
  class CreateUser
    include Wisper::Publisher

    module Internals
      # This very well may be more general-purpose than just this action...
      class UserDataConverter
        attr_reader :data

        def initialize(input)
          @data = parse input
        end

        private

        def parse(input)
          case input
          when String
            attrs = FancyOpenStruct.new CGI.parse(input)
          else # Hash or OpenStruct
            attrs = FancyOpenStruct.new input
          end
          {}.tap do |ret|
            attrs.each.map { |k, v| ret[k] = Array(v).first }
          end
        end
      end # class UserDataConverter
    end # module Internals
    private_constant :Internals
    include Internals

    def initialize(current_user, user_data)
      @current_user = current_user
      @user_data = UserDataConverter.new(user_data).data
      @user_slug = @user_data[:slug] || @user_data[:name].parameterize
      @user_data.delete :slug # will be recreated on successful save
    end

    def execute
      require_guest_user
      verify_entity_does_not_exist
      add_user_entity_to_repo
      broadcast_success entity
    rescue RuntimeError => error
      broadcast_failure error.message
    end

    private

    attr_reader :current_user, :user_data, :entity

    def broadcast_failure(payload)
      broadcast :failure, payload
    end

    def broadcast_success(payload)
      broadcast :success, payload
    end

    def add_user_entity_to_repo
      new_entity = UserEntity.new(user_data)
      result = user_repo.add new_entity
      @entity = result.entity
      return if result.success?
      new_entity.valid? # nope; now error messages are built
      fail_for attributes: user_data, messages: new_entity.errors.full_messages
    end

    def require_guest_user
      guest_user = user_repo.guest_user.entity
      return if current_user.name == guest_user.name
      fail_for messages: [already_logged_in_message]
    end

    def verify_entity_does_not_exist
      result = user_repo.find_by_slug @user_slug
      return unless result.success?
      fail_for messages: [entity_already_exists_message], attributes: user_data
    end

    # Support methods

    # ... for #require_guest_user

    def already_logged_in_message
      "Already logged in as #{current_user.name}!"
    end

    def user_repo
      @user_repo ||= UserRepository.new
    end

    # ... for #verify_entity_does_not_exist

    def entity_already_exists_message
      "A record identified by slug '#{@user_slug}' already exists!"
    end

    # ... for others

    def fail_for(options)
      messages = options.fetch :messages, []
      attributes = options.fetch :attributes, nil
      data = { messages: messages }
      data[:attributes] = attributes if attributes
      fail data.to_json
    end
  end # class Actions::CreateUser
end # module Actions
