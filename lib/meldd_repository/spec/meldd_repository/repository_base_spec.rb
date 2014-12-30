
require 'spec_helper'

require 'ostruct'

require 'meldd_repository/repository_base'

# Used for mocking up a Repository.
class FakeDao
  def initialize(_)
  end

  def save
    true
  end
end # class FakeDao

# Gives a Repository something to call.
class FakeFactory
  def self.create(record)
    record
  end
end

# MelddRepository: includes base Repository class wrapping database access.
module MelddRepository
  describe RepositoryBase do

    it 'has a constructor that requires two parameters' do
      expect { described_class.new }.to raise_error ArgumentError
      expect { described_class.new 'foo' }.to raise_error ArgumentError
      expect { described_class.new 'foo', 'bar' }.not_to raise_error
    end

    describe 'method #add' do
      it 'requires one parameter' do
        obj = described_class.new 'foo', 'bar'
        method = obj.public_method :add
        expect(method.arity).to eq 1
      end

      it 'requires one parameter that has an #attributes method' do
        obj = described_class.new FakeFactory, FakeDao
        message = %(undefined method `attributes' for "foo":String)
        expect { obj.add 'foo' }.to raise_error NoMethodError, message
        arg = OpenStruct.new attributes: 'foo'
        expect { obj.add arg }.to raise_error NoMethodError
        arg = OpenStruct.new attributes: []
        expect { obj.add arg }.not_to raise_error
      end
    end # describe 'method #add'
  end # describe MelddRepository::RepositoryBase
end # module MelddRepository
