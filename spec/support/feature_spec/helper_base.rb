
# Base class for other feature-spec support classes; knows about spec and user
# fields, and actions common to most/all feature specs (setting up user fields,
# for example).
class FeatureSpecHelperBase
  def initialize(spec_obj)
    @s = spec_obj
  end

  protected

  attr_reader :s

  def setup_user_fields
    s.instance_eval do
      @user_bio ||=       'I am what I am. You are what you eat.'
      @user_email ||=     'jruser@example.com'
      @user_name ||=      'J Random User'
      @user_password ||=  's00persecret'
    end
  end
end
