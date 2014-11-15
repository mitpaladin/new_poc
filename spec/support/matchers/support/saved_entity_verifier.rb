
# Veriies that an entity has required fields and omits prohibited fdields.
class SavedEntityVerifier
  attr_reader :reasons

  def initialize(source, actual, &block)
    @source, @actual = source, actual
    @required_in_both, @required_in_source, @required_in_actual = [], [], []
    @reasons = []
    instance_eval(&block) if block
  end

  def verify
    verify_required_common_fields
    verify_required_exclusive_fields true
    verify_required_exclusive_fields false
    @reasons.flatten!
    @reasons.empty?
  end

  private

  attr_reader :source, :actual, :required_in_source, :required_in_actual
  attr_writer :reasons

  def check_prohibited_field(obj, field, in_source)
    return unless obj.send(field)
    which_str = which_str_for true, in_source
    @reasons << field_exist_reason(field, false, which_str)
  end

  def check_required_field(obj, field, in_source)
    return if obj.send(field)
    which_str = which_str_for true, in_source
    @reasons << field_exist_reason(field, true, which_str)
  end

  def field_exist_reason(field, must, which)
    field_str = field.to_s.split('_').join ' '
    must_str = must ? 'must' : 'must not'
    [which.capitalize, must_str, 'have a', field_str, 'field'].join(' ')
  end

  def required_in_both(*attrs)
    @required_in_both = Array(attrs)
  end

  def required_in_source(*attrs)
    @required_in_source = Array(attrs)
  end

  def required_in_actual(*attrs)
    @required_in_actual = Array(attrs)
  end

  def add_reason_if(field_sym)
    actual_field = actual.send field_sym
    source_field = source.send field_sym
    return if actual_field == source_field
    message = %(#{field_sym} fields do not match: got #{actual_field} but ) +
              %(expected #{source_field})
    @reasons << message
  end

  def verify_required_common_fields
    @required_in_both.each { |field| add_reason_if field }
  end

  def direction_for_musts(in_source)
    must, must_not = if in_source
                       [source, actual]
                     else
                       [actual, source]
                     end
    [must, must_not]
  end

  def verify_required_exclusive_fields(in_source)
    fields = in_source ? @required_in_source : @required_in_actual
    return if fields.nil? || fields.empty?
    must_have, must_not_have = direction_for_musts(in_source)
    fields.each do |field|
      check_required_field must_have, field, in_source
      check_prohibited_field must_not_have, field, in_source
    end
  end

  def which_str_for(flag, in_source)
    flag == in_source ? 'source' : 'actual'
  end
end
