
# Base class for other feature-spec support classes; knows about spec and user
# fields, and actions common to most/all feature specs (setting up user fields,
# for example).
class FeatureSpecHelperBase
  def initialize(spec_obj)
    @s = spec_obj
  end

  protected

  attr_reader :s
end
