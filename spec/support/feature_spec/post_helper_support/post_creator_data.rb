
require_relative '../../sequencer'

module PostHelperSupport
  # Encapsulates/sequences data suitable for post generation.
  class PostCreatorData
    attr_reader :post_status

    def initialize(params = {})
      title_format = params.fetch :post_title, 'Post Title %d'
      post_start = params.fetch :post_start, 0
      @post_title = Sequencer.new title_format, post_start
      format_str = 'This is *another* post body. (Number %d in a series.)'
      body_format = params.fetch :post_body, format_str
      @post_body = Sequencer.new body_format, post_start
      @post_status = force_allowed_status(params.fetch :post_status, 'public')
    end

    def post_body
      @post_body.to_s
    end

    def post_title
      @post_title.to_s
    end

    def step(new_status = nil)
      @post_body.step
      @post_title.step
      @post_status = force_allowed_status new_status
    end

    private

    def force_allowed_status(status)
      return status if %w(public draft).include? status
      'public'
    end
  end # class PostHelperSupport::PostCreatorData
end # module PostHelperSupport
