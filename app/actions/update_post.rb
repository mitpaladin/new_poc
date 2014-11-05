
module Actions
  # Wisper-based command object called by Posts controller #update action.
  class UpdatePost
    include Wisper::Publisher

    def initialize(post_slug, post_data, current_user)
      @post_slug = post_slug
      @post_data = filter_post_data post_data
      @current_user = current_user
    end

    # FIXME: Validation rules for post_data?
    def execute
      return broadcast_failure(guest_user_prohibited) unless logged_in?
      return broadcast_failure(only_author_permitted) unless by_author?
      entity = updated_entity
      return broadcast_failure(invalid_update) unless valid_attributes?(entity)
      result = post_repo.update entity
      return broadcast_failure(result) unless result.success?
      broadcast_success result
    end

    private

    attr_reader :post_data, :post_slug, :current_user

    def broadcast_failure(payload)
      broadcast :failure, payload
    end

    def broadcast_success(payload)
      broadcast :success, payload
    end

    def by_author?
      result = post_repo.find_by_slug(post_slug)
      result.success? && current_user.name == result.entity.author_name
    end

    def filter_post_data(post_data)
      data = post_data.symbolize_keys.select do |attrib, _value|
        permitted_attribs.include? attrib
      end
      FancyOpenStruct.new data
    end

    def guest_user
      user_repo.guest_user.entity
    end

    def guest_user_prohibited
      errors = { user: 'Not logged in as a registered user!' }
      StoreResult.new success: false, entity: nil,
                      errors: ErrorFactory.create(errors)
    end

    def invalid_update
      errors = { post: 'Invalid attribute values specified for update!' }
      StoreResult.new success: false, entity: nil,
                      errors: ErrorFactory.create(errors)
    end

    def logged_in?
      current_user.name != guest_user.name
    end

    def only_author_permitted
      errors = { user: 'Not logged in as the author of this post!' }
      StoreResult.new success: false, entity: nil,
                      errors: ErrorFactory.create(errors)
    end

    def permitted_attribs
      [:title, :body, :image_url, :pubdate]
    end

    def post_repo
      @post_repo ||= PostRepository.new
    end

    def updated_entity
      attributes = post_repo.find_by_slug(post_slug).entity.attributes
      post_data.each_key do |attrib|
        attributes[attrib] = post_data[attrib].to_s.strip
      end
      PostEntity.new attributes
    end

    def user_repo
      @user_repo ||= UserRepository.new
    end

    def valid_attributes?(entity)
      entity.title.present? &&
          (entity.body.present? || entity.image_url.present?)
    end
  end # class Actions::UpdatePost
end # module Actions
