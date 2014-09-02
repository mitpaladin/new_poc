
# Class to validate proposed update to a post, with a twist.
# 1. The "post" parameter may be either an object with accessor methods for the
#    fields we're interested in (e.g., #title) or, if not, must be a Hash-like
#    object with keys for the fields (e.g., :title).
# 2. Similarly, the "data" parameter may be either an object with accessor
#    methods or a Hash-like object.
# See Issue #89 for more details.
class PostUpdateValidator
  attr_reader :messages

  def initialize(post, data)
    @post = post
    @data = data
    @messages = {}
  end

  def combined_data
    data = internal_convert(@post).merge internal_convert(@data)
    FancyOpenStruct.new data
  end

  def valid?
    return true if @data.empty?
    validate combined_data
  end

  private

  def internal_convert(data)
    source = if data.respond_to? :attributes # it's an ActiveRecord-ish instance
               data.attributes
             else # it better be hash-like
               data.to_h
             end
    FancyOpenStruct.new source
  end

  def validate_single_field(data, field_sym)
    return if data.send(field_sym).to_s.present?
    message = format '%s must be present', field_sym.to_s.capitalize
    @messages[field_sym] = message
  end

  def validate_either_or_fields(data, field1_sym, field2_sym)
    field1 = data.send field1_sym
    field2 = data.send field2_sym
    return if field1.present? || field2.present?

    str1 = field1_sym.to_s.humanize.downcase
    str2 = field2_sym.to_s.humanize.downcase
    format_str = '%s must be present if %s is missing or blank'
    @messages[field1_sym] = format format_str, str1.capitalize, str2
    @messages[field2_sym] = format format_str, str2.capitalize, str1
  end

  def validate(data)
    @messages = {}
    validate_single_field data, :title
    validate_single_field data, :author_name
    validate_either_or_fields data, :body, :image_url
    @messages.empty?
  end
end # class PostUpdateValidator
