
module DSO
  # A Post must have methods #valid? and #publish. If the instance passed in
  # returns a truthy value from #valid?, its #publish method is called and
  # its return value is returned as the DSO outcome. Simple enough for you?
  class PostPublisher < ActiveInteraction::Base
    validate :validate_post
    model :post, class: parent.parent::Post

    def execute
      post.publish
    end

    private

    def validate_post
      post.valid?
    end
  end
end # module DSO
