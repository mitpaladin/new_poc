
module Actions
  # Wisper-based command object called by Posts controller #update action.
  class UpdatePost
    include Wisper::Publisher

    def initialize(post_slug, post_data, current_user)
      @post_slug = post_slug
      @post_data = filter_post_data post_data
      @current_user = current_user
      @entity = dummy_entity
    end

    def execute
      prohibit_guest_access
      validate_slug
      verify_user_is_author
      @entity = update_entity
      broadcast_success entity
    rescue RuntimeError => e
      broadcast_failure e.message
    end

    private

    attr_reader :post_data, :post_slug, :current_user, :entity

    def broadcast_failure(payload)
      broadcast :failure, payload
    end

    def broadcast_success(payload)
      broadcast :success, payload
    end

    def prohibit_guest_access
      return unless guest_user.name == current_user.name
      fail [guest_user_not_authorised_message].to_json
    end

    def update_entity
      attributes = attributes_from_repo.merge post_data.to_h
      new_entity = PostEntity.new attributes
      fail new_entity.errors.full_messages.to_json unless new_entity.valid?
      new_entity
    end

    def validate_slug
      result = post_repo.find_by_slug post_slug
      fail error_message_for_slug unless result.success?
      @entity = result.entity
    end

    def verify_user_is_author
      return if current_user.name == entity.author_name
      fail [error_message_for_non_author].to_json
    end

    # Support methods

    # ... for #initialize

    def dummy_entity
      Naught.build do |config|
        config.impersonate PostEntity
        config.predicates_return false
        # def author_name
        #   'Guest User'
        # end
      end.new
    end

    def filter_post_data(post_data)
      data = post_data.symbolize_keys.select do |attrib, _value|
        attributes_permitted_from_form.include? attrib
      end
      FancyOpenStruct.new data
    end

    def attributes_permitted_from_form
      [:title, :body, :image_url, :pubdate, :post_status]
    end

    # ... for #prohibit_guest_access

    def guest_user
      user_repo.guest_user.entity
    end

    def guest_user_not_authorised_message
      'Not logged in as a registered user!'
    end

    def post_repo
      @post_repo ||= PostRepository.new
    end

    # ... for #update_entity

    def attributes_from_repo
      ret = post_repo.find_by_slug(post_slug).entity.attributes
      ret
    end

    # ... for #validate_slug

    def error_message_for_slug
      "Cannot find post identified by slug: '#{post_slug}'!"
    end

    def user_repo
      @user_repo ||= UserRepository.new
    end

    # ... for #verify_user_is_author
    def error_message_for_non_author
      "User #{current_user.name} is not the author of this post!"
    end
  end # class Actions::UpdatePost
end # module Actions
