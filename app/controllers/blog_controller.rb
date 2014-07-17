
# A controller should assign resources and redirect flow. Full stop.
class BlogController < ApplicationController
  after_action :verify_authorized,  except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @blog = policy_scope(BlogData.first).decorate
    authorize @blog
  end
end # class BlogController
