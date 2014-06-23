
# Old-style junk drawer of view-helper functions, etc.
module PostsHelper
  def new_post_form_attributes
    {
      html:   {
        class:  'form-horizontal new_post',
        id:     'new_post'
      },
      role:   'form',
      url:    posts_path
    }
  end
end
