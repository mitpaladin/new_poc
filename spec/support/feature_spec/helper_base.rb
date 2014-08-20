
require_relative 'post_helper_support/post_creator_data'

# Base class for other feature-spec support classes; knows about spec and user
# fields, and actions common to most/all feature specs (setting up user fields,
# for example).
class FeatureSpecHelperBase
  def initialize(spec_obj, data)
    @s = spec_obj
    @data = data
  end

  protected

  attr_reader :data, :s
end
