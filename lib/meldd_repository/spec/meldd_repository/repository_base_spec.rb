
require 'spec_helper'

require 'ostruct'
require 'active_model/errors'

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

      describe 'returns a StoreResult instance that' do
        let(:result) { obj.add record }
        let(:record) { OpenStruct.new attributes: { field1: 'value' } }

        context 'reports success in multiple ways, including' do
          let(:obj) { described_class.new FakeFactory, FakeDao }

          it 'has a #success? method returning true' do
            expect(result).to be_success
          end

          it 'has an #errors method returning an empty Array' do
            errors = result.errors
            # Remember, #to_a is explicit conversion; #to_ary is implicit.
            expect(errors).to respond_to :to_ary
            expect(errors).to be_empty
          end

          it 'has an #entity method returning a non-nil object instance' do
            expect(result.entity).not_to be nil
          end
        end # context 'reports success in multiple ways, including'

        context 'reports failure in multiple ways, including' do
          let(:fake_dao_class) do
            Class.new(FakeDao) do
              def save
                false
              end

              def errors
                ActiveModel::Errors.new(self).tap do |e|
                  e.add :field1, 'is invalid'
                end
              end
            end
          end
          let(:obj) { described_class.new FakeFactory, fake_dao_class }

          it 'has a #success? method returning false' do
            expect(result).not_to be_success
          end

          it 'has an #errors method returning an array of error objects' do
            expect(result.errors.count).to eq 1
            error = result.errors.first
            expect(error).to be_a Hash
            expect(error.size).to eq 2
            expect(error[:field]).to eq 'field1'
            expect(error[:message]).to eq 'is invalid'
          end

          it 'has an #entity method returning nil' do
            expect(result.entity).to be nil
          end
        end # context 'reports failure in multiple ways, including'
      end # describe 'returns a StoreResult instance that'
    end # describe 'method #add'
  end # describe MelddRepository::RepositoryBase
end # module MelddRepository
