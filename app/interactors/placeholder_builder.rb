
module DSO
  # "Placeholder" blog posts, just to have something to show in the index view.
  class PlaceholderBuilder < ActiveInteraction::Base
    interface :blog, methods: [:new_post]

    def execute
      data_source.each do |data|
        post = blog.new_post title: data.title, body: data.body
        post.publish
      end
      true  # we succeeded, didn't we?
    end

    def data_source
      ret = []
      item = FancyOpenStruct.new title: 'Paint just applied'
      item.body = "Paint just applied. It's a lovely orangey-purple!"
      ret << item
      item = FancyOpenStruct.new title: 'Still wet'
      item.body = 'Paint is still quite wet. No bubbling yet!'
      ret << item
    end
  end # class DSO::PlaceholderBuilder
end # module DSO
