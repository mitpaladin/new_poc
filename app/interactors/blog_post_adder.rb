
module DSO
  # A Post must have methods #valid? and #publish. If the instance passed in
  # returns a truthy value from #valid?, its #publish method is called and
  # its return value is returned as the DSO outcome. Simple enough for you?
  class BlogPostAdder < ActiveInteraction::Base
    validate :validate_post
    validate :validate_status
    model :post, class: parent.parent::Post
    string :status, default: 'draft', strip: true

    def execute
      if draft?
        post.add_to_blog
      else
        post.publish
      end
      post
    end

    private

    def draft?
      status == 'draft'
    end

    def validate_post
      return true if post.valid?
      post.error_messages.each { |message| errors.add :post, message }
    end

    def validate_status
      %w(draft public).include? status
    end
  end
end # module DSO
