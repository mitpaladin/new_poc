
# Support classes for UserDataValidator.
module UserDataValidation
  # Validates user name, per current rules e.g., from create-user form input.
  class NameValidator
    def initialize(name)
      @errors = []
      @name = name.to_s
    end

    def errors
      valid?  # ensure that validation is performed
      @errors.map { |message| ['Name', message].join ' ' }
    end

    def valid?
      !name_is_missing_or_blank? &&
          name_is_available? &&
          name_is_properly_formatted? &&
          !name_has_repeated_whitespace?
    end

    private

    attr_reader :name

    def add_error(message)
      # protect against redundant adding of error messages
      # (e.g. #errors following #valid?)
      return @errors if @errors.include? message
      @errors << message
    end

    def name_has_repeated_whitespace?
      rebuilt_name = name.split.join(' ')
      (name != rebuilt_name).tap do |has_repeats|
        add_error('may not contain adjacent whitespace') if has_repeats
      end
    end

    def name_is_properly_formatted?
      name.match(/\A(\S+?.+?\S+?)\z/).present?.tap do |is_properly_formatted|
        add_error('is not properly formatted') unless is_properly_formatted
      end
    end

    def name_is_missing_or_blank?
      name.strip.empty?.tap do |missing_or_blank|
        add_error('may not be missing or blank') if missing_or_blank
      end
    end

    def name_is_available?
      (!user_repo.find_by_name(name).success?).tap do |is_available|
        add_error('is not available') unless is_available
      end
    end

    def user_repo
      @user_repo ||= UserRepository.new
    end
  end # class UserDataValidation::NameValidator
end # module UserDataValidation
