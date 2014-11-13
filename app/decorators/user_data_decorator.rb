
require 'draper'

require 'decorator_shared/timestamp_builder'

# UserDataDecorator: Draper Decorator, aka ViewModel, for the UserData model.
class UserDataDecorator < Draper::Decorator
  decorates_finders
  delegate_all
  include DecoratorShared

  def build_index_row_for(post_count)
    h.content_tag :tr, nil, build_index_row_attrs, false do
      h.concat build_name_item
      h.concat build_posts_item(post_count)
      h.concat build_member_since_item
    end
  end

  private

  def build_index_row_attrs
    ret = {}
    ret[:class] = 'info' if name == h.current_user.name
    ret
  end

  def build_member_since_item
    h.content_tag :td, timestamp_for(created_at)
  end

  def build_name_item
    h.content_tag :td,
                  h.link_to(name, h.user_path(name.parameterize)),
                  nil,
                  false
  end

  def build_posts_item(count)
    h.content_tag :td, count.to_s
  end
end # class UserDataDecorator
