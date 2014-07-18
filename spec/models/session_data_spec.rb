
require 'spec_helper'

describe SessionData do
  let(:klass) { SessionData }

  describe 'initialisation' do
    describe 'succeeds when' do
      it 'no parameters are specified' do
        expect { klass.new }.to_not raise_error
      end

      it 'with an :id parameter' do
        expect { klass.new id: 24 }.to_not raise_error
      end
    end # describe 'succeeds when'
  end # describe 'initialisation'

  it 'fails when accessing an invalid parameter is attempted' do
    obj = klass.new id: 24
    message = 'unknown attribute: foo'
    error_class = ActiveAttr::UnknownAttributeError
    expect { obj[:foo] }.to raise_error error_class, message
  end

  it 'can set an :id attribute explicitly' do
    obj = klass.new
    obj[:id] = 42
    expect(obj[:id]).to be 42
  end

  it 'does not exist' do
    expect(klass.new).to_not exist
  end

  it 'implements class method :where which returns a new class instance' do
    where_got = klass.where 'anything at all goes here'
    expect(where_got).to be_a klass
    expect(where_got).to_not exist
    expect(where_got[:id]).to be_nil
  end
end
