
require 'spec_helper'
require 'instance_variable_setter'

# Test class to demonstrate InstanceVariableSetter (scenario 1)
class TestClassWithInitBlock
  attr_reader :foo, :bar, :baz
  def initialize(attrs = {})
    InstanceVariableSetter.new(self) do
      allow_attributes %w(foo bar)
      # or: allow_attributes [:foo, :bar]
      set attrs
    end
  end
end

# Test class to demonstrate InstanceVariableSetter (scenario 2)
class TestClassWithCallback
  attr_reader :foo, :bar, :baz
  def initialize(attrs = {})
    InstanceVariableSetter.new(self).set attrs
  end

  def init_attrib_keys
    %w(foo bar) # or [:foo, :bar]
  end
end

describe InstanceVariableSetter do
  describe 'can be initialised using a' do
    let(:test_params) { { foo: 'Hello', bar: 21, baz: true } }

    # Note that we have no expectation that the ivars assigned to are the
    # complete set of ivars for @test_obj. It's perfectly valid to use the
    # InstanceVariableSetter class to initialise a *subset of* ivars for the
    # target object; we simply expect that ivars not explicitly permitted *that
    # are not otherwise initialised* have `nil` values.
    after :each do
      expect(@test_obj.foo).to eq test_params[:foo]
      expect(@test_obj.bar).to eq test_params[:bar]
      expect(@test_obj.baz).to be nil
    end

    it 'block' do
      @test_obj = TestClassWithInitBlock.new test_params
    end

    it 'callback' do
      @test_obj = TestClassWithCallback.new test_params
    end
  end # describe 'can be initialised using a'
end # describe InstanceVariableSetter
