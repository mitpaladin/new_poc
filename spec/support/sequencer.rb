
# Uses a format string to build sequenced strings via repeated #to_s calls.
class Sequencer
  include Comparable
  attr_accessor :next_index
  attr_reader :auto_step

  def initialize(format_str, start = 0, auto_step = false)
    @next_index = start + 1
    @format_str = format_str
    @auto_step = auto_step
  end

  def step
    @next_index += 1
  end

  def to_str
    ret = format format_str, next_index
    step if auto_step
    ret
  end

  def to_s
    to_str
  end

  def <=>(other)
    (@next_index == other.instance_variable_get(:@next_index)) &&
      (@format_str == other.instance_variable_get(:@format_str)) &&
      (@auto_step == other.instance_variable_get(:@auto_step))
  end

  protected

  attr_reader :format_str
end # class Sequencer
