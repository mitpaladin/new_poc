
require 'spec_helper'

# Implements no new behaviour; i.e., behaves exactly as ApplicationPolicy does.
class FooPolicy < ApplicationPolicy
end

# Dummy "model" class for testing ApplicationPolicy.
class Foo
  include ActiveAttr::BasicModel

  def exists?
    false
  end

  def id
    2_718_281_828
  end

  def self.where(*)
    Foo.new
  end
end

describe ApplicationPolicy do
  subject(:policy) { FooPolicy.new user, record }
  let(:record) { Foo.new }
  let(:user) { FactoryGirl.build :user_datum }

  [
    :index,
    :show,
    :create,
    :new,
    :update,
    :edit,
    :destroy
  ].each { |action| it { should_not permit action } }

  it 'verifies that #scope returns the class of the record' do
    foo = policy.scope
    expect(foo).to be Foo
  end

end # describe ApplicationPolicy
