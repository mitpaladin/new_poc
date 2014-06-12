
# Module containing "boundary-layer objects" between DSOs and implementation.
module BLO
  # Boundary-layer object for database-stored data re Post data.
  class PostDataBoundary
    def self.entry?(entry)
      attribs = { title: entry.title, body: entry.body }
      PostData.where(attribs).any?
    end

    def self.load_all
      ret = []
      PostData.all.each { |post| ret << Post.new(post.attributes) }
      ret
    end

    def self.save_entry(entry)
      PostData.find_or_create_by title: entry.title, body: entry.body
    end
  end # class BLO::PostDataBoundary
end # module BLO
