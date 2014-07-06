
# Generates an array of random items as built by a proc passed to #generate.
class RandomItemArrayGenerator
  def initialize(value_limit)
    init_indexes value_limit
  end

  def generate(sample_size, item_maker = -> (_index, _current) {})
    ret = []
    sample_size.times do |index|
      current = next_available_index
      ret << item_maker.call(index, current)
      @indexes[current] = index
    end
    ret
  end

  private

  def init_indexes(value_limit)
    @indexes = [-1] * value_limit
    @indexes[value_limit - 1] = 999_999
  end

  def next_available_index
    current = @indexes.count - 1
    current = rand(@indexes.count) until @indexes[current] == -1
    current
  end
end
