
require 'newpoc/action/user/edit'

require_relative 'users_controller/edit_failure_redirector'

require_relative 'users_controller/action/create'
require_relative 'users_controller/action/index'
require_relative 'users_controller/action/new'
require_relative 'users_controller/action/show'
require_relative 'users_controller/action/update'
require_relative 'users_controller/create_failure'

# UsersController: actions related to Users within our "fancy" blog.
class UsersController < ApplicationController
  include Internals

  def index
    Action::Index.new(UserRepository.new)
      .subscribe(self, prefix: :on_index)
      .execute
  end

  def new
    Action::New.new(current_user: current_user,
                    user_repo: UserRepository.new)
      .subscribe(self, prefix: :on_new).execute
  end

  def create
    action = Action::Create.new current_user: current_user,
                                user_data: params[:user_data]
    action.subscribe(self, prefix: :on_create).execute
  end

  def edit
    action = Newpoc::Action::User::Edit.new params[:id], current_user,
                                            UserRepository.new
    action.subscribe(self, prefix: :on_edit).execute
  end

  def show
    Action::Show.new(target_slug: params[:id],
                     user_repository: UserRepository.new)
      .subscribe(self, prefix: :on_show).execute
  end

  def update
    action_params = {
      user_data: params[:user_data],
      current_user: current_user
    }
    action = Action::Update.new(action_params)
    action.subscribe(self, prefix: :on_update).execute
  end

  # Action responders must be public to receive Wisper notifications; see
  # https://github.com/krisleech/wisper/issues/75 for relevant detail. (Needless
  # to say that, even though these are public methods, they should never be
  # called directly.)

  def on_create_success(payload)
    @user = payload
    redirect_to root_url, flash: { success: 'Thank you for signing up!' }
  end

  def on_create_failure(payload)
    @user = user_for_create_failure(payload, self)

    render 'new'
  end

  def on_edit_success(payload) # rubocop:disable Style/TrivialAccessors
    @user = payload
  end

  def on_edit_failure(payload)
    EditFailureRedirector.new(payload: payload, helper: self).go
  end

  def on_index_success(payload) # rubocop:disable Style/TrivialAccessors
    @users = payload
  end

  def on_new_success(payload) # rubocop:disable Style/TrivialAccessors
    @user = payload
  end

  def on_new_failure(payload)
    alert = "Already logged in as #{payload.name}!"
    redirect_to root_path, flash: { alert: alert }
  end

  def on_show_success(payload) # rubocop:disable Style/TrivialAccessors
    @user = payload
  end

  def on_show_failure(payload)
    alert = "Cannot find user identified by slug #{payload}!"
    redirect_to users_path, flash: { alert: alert }
  end

  def on_update_success(payload)
    @user = payload
    message = 'You successfully updated your profile'
    redirect_to user_path(@user.slug), flash: { success: message }
  end

  def on_update_failure(payload)
    data = FancyOpenStruct.new YAML.load(payload)
    @user = Newpoc::Entity::User.new data.entity if data.entity
    flash[:alert] = data.messages.join '<br/>'
    return render 'edit' if data.entity
    redirect_to root_path
  end
end # class UsersController
