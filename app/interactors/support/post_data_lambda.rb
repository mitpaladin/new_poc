
# Module containing domain service-level objects, aka DSOs or interactors.
module DSO
  POST_DATA_LAMBDA = lambda do |dso|
    dso.string :title, default: '', strip: true
    dso.string :body, default: '', strip: true
    dso.string :image_url, default: '', strip: true
    dso.string :author_name, default: '', strip: true
  end
end
