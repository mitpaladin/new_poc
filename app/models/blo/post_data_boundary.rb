
# Module containing "boundary-layer objects" between DSOs and implementation.
module BLO
  # Internal support code used by BLOs.
  module Internal
    def attribs_for(obj)
      ret = {}
      [:title, :body, :image_url].each do |k|
        ret[k] = obj.send k
      end
      ret
    end
  end

  # Boundary-layer object for database-stored data re Post data.
  class PostDataBoundary
    extend Internal

    def self.entry?(entry)
      attribs = { title: entry.title, body: entry.body }
      PostData.where(attribs).any?
    end

    def self.full_error_messages(entry)
      datum = PostData.find_or_initialize_by attribs_for(entry)
      datum.valid?
      datum.errors.full_messages
    end

    def self.load_all
      ret = []
      PostData.all.each { |post| ret << Post.new(post.attributes) }
      ret
    end

    def self.save_entry(entry)
      datum = PostData.find_or_create_by attribs_for(entry)
      datum.save
    end

    def self.valid?(post)
      datum = PostData.find_or_initialize_by attribs_for(post)
      datum.valid?
    end
  end # class BLO::PostDataBoundary
end # module BLO
