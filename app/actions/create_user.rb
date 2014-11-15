
module Actions
  # Wisper-based command object called by Users controller #new action.
  class CreateUser
    include Wisper::Publisher
    attr_reader :current_user, :user_data

    def initialize(current_user, user_data)
      @current_user = current_user
      @user_data = user_data.to_h.symbolize_keys
      @user_data.delete :slug # will be recreated on successful save
      @errors = []
    end

    def execute
      validate_inputs
      return broadcast_failure unless @errors.empty?
      result = user_repo.add UserEntity.new(user_data)
      return broadcast_failure(result) unless result.success? # needed?
      broadcast_success result
    end

    private

    def broadcast_failure
      broadcast :failure, failure_result
    end

    def broadcast_success(payload)
      broadcast :success, payload
    end

    def build_errors
      errors = errors_object
      @errors.each { |error| errors.add error.keys.first, error.values.first }
      ErrorFactory.create errors
    end

    def validate_inputs
      guest_user = user_repo.guest_user.entity
      if guest_user.name != current_user.name
        @errors << { user: "Already logged in as #{current_user.name}!" }
      end
      @errors += UserDataValidator.new(user_data).errors
    end

    # dependencies; candidates for future injection

    def errors_object
      ActiveModel::Errors.new current_user
    end

    def failure_result
      StoreResult.new success: false, errors: build_errors,
                      entity: UserEntity.new(user_data)
    end

    def user_repo
      @user_repo ||= UserRepository.new
    end
  end # class Actions::CreateUser
end # module Actions
