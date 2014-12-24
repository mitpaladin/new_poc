
require 'spec_helper'
require 'instance_variable_setter'

# Test class to demonstrate InstanceVariableSetter (scenario 2)
class TestClassWithCallback
  attr_reader :foo, :bar
  def initialize(attrs = {})
    InstanceVariableSetter.new(self).set attrs
  end

  def init_attrib_keys
    %w(foo bar) # or [:foo, :bar]
  end
end

describe InstanceVariableSetter do
  it 'can be initialised using a callback' do
    @test_obj = TestClassWithCallback.new foo: 'Hello', bar: 21
    expect(@test_obj.foo).to eq 'Hello'
    expect(@test_obj.bar).to eq 21
    expect(@test_obj.instance_variables).to eq [:@foo, :@bar]
  end
end # describe InstanceVaribleSetter
