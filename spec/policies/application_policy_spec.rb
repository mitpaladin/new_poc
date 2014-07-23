
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
  subject { FooPolicy }
  let(:record) { Foo.new }
  let(:user) { FactoryGirl.build :user_datum }

  [
    :index?,
    :show?,
    :create?,
    :new?,
    :update?,
    :edit?,
    :destroy?
  ].each do |query|
    permissions query do
      action = query.to_s.chop
      it "does not permit the user to invoke the :#{action} action" do
        expect(subject).not_to permit(user, record)
      end
    end
  end

  it 'verifies that #scope returns the class of the record' do
    foo = subject.new(user, record).scope
    expect(foo).to be Foo
  end

end # describe ApplicationPolicy
