
require 'spec_helper'

require 'ostruct'
require 'active_model/errors'

require 'newpoc/repository/base'

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

shared_examples 'a failed StoreResult' do
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
end

module Newpoc
  # Repositories mediate between domain entities and implementation-level DAOs.
  module Repository
    # Base class of all Repository classes for app.
    describe Base do
      it 'has a constructor that requires two parameters' do
        expect { described_class.new }.to raise_error ArgumentError
        expect { described_class.new 'factory' }.to raise_error ArgumentError
        expect { described_class.new 'factory', 'dao' }.not_to raise_error
      end

      describe 'method #add' do
        it 'requires one parameter' do
          obj = described_class.new 'factory', 'dao'
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
            let(:dao_subclass) do
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
            let(:obj) { described_class.new FakeFactory, dao_subclass }

            it_behaves_like 'a failed StoreResult' # uses `result`
          end # context 'reports failure in multiple ways, including'
        end # describe 'returns a StoreResult instance that'
      end # describe 'method #add'

      describe 'method #all' do
        context 'with no entries' do
          it 'returns an empty Array' do
            dao = OpenStruct.new all: []
            obj = described_class.new 'factory', dao
            expect(obj.all).to eq []
          end
        end # context 'with no entries'

        context 'with entries' do
          let(:all_data) { [{ attr1: 'value1' }, { attr1: 'value2' }] }
          let(:dao) { OpenStruct.new all: all_data }
          let(:factory) do
            Class.new do
              def self.create(record)
                record.inspect
              end
            end # class
          end
          let(:obj) { described_class.new factory, dao }

          it 'returns an Array' do
            expect(obj.all).to be_an Array
          end

          it 'has the correct number of entries' do
            expect(obj.all.count).to eq all_data.count
          end

          it 'has the correct entry for each input data item' do
            obj.all.each_with_index do |entry, index|
              expect(entry).to eq all_data[index].inspect
            end
          end
        end # context 'with entries'
      end # describe 'method #all'

      describe 'method #find_by_slug' do
        let(:obj) { described_class.new FakeFactory, dao_class }
        let(:record) { OpenStruct.new attributes: { slug: slug } }
        let(:slug) { 'the-slug' }

        context 'where the target exists' do
          let(:dao_class) do
            Class.new(FakeDao) do
              def self.where(_opts = :chain, *_rest)
                [OpenStruct.new(attributes: { slug: 'the-slug' })]
              end
            end # class
          end

          before :each do
            obj.add record
          end

          describe 'returns a successful StoreResult containing' do
            let(:result) { obj.find_by_slug slug }

            it 'a :success? method returning true' do
              expect(result).to be_success
            end

            it 'an :errors method returning an empty Array' do
              expect(result.errors).to respond_to :to_ary
              expect(result.errors).to be_empty
            end

            it 'an :entity method returning the retrieved entity' do
              expect(result.entity).not_to be_nil
              expect(result.entity.slug).to eq record.slug
            end
          end # describe 'returns a successful StoreResult containing'
        end # context 'where the target exists'

        context 'where the target does not exist' do
          let(:dao_class) do
            Class.new(FakeDao) do
              def self.where(_opts = :chain, *_rest)
                []
              end
            end # class
          end

          describe 'returns an unsuccessful StoreResult containing' do
            let(:result) { obj.find_by_slug slug }

            it 'a :success? method returning false' do
              expect(result).not_to be_success
            end

            describe 'an Array' do
              it 'containing a single entry' do
                expect(result.errors).to respond_to :to_ary
                expect(result.errors.count).to eq 1
              end

              describe 'containing an error-information Hash that' do
                let(:error) { result.errors.first }

                it 'has two fields' do
                  expect(error).to respond_to :to_hash
                  expect(error.keys).to eq [:field, :message]
                end

                it 'has the correct :field entry' do
                  expect(error[:field]).to eq 'base'
                end

                it 'has the correct :message entry' do
                  message = "A record with 'slug'=#{slug} was not found."
                  expect(error[:message]).to eq message
                end
              end # describe 'containing an error-information Hash that'
            end # describe 'an Array'

            it 'an :entity method returning nil' do
              expect(result.entity).to be_nil
            end
          end # describe 'returns an unsuccessful StoreResult containing'
        end # context 'where the target does not exist'
      end # describe 'method #find_by_slug'

      describe 'method #update' do
        let(:dao_subclass) do
          the_record = record
          klass = Class.new(FakeDao) do
            def self.where(_opts = :chain, *_rest)
              [rec]
            end
          end # class
          # :define_method creates a *closure*, not an ordinary method
          klass.class.send(:define_method, :rec) do
            the_record
          end
          klass
        end
        let(:obj) { described_class.new FakeFactory, dao_subclass }
        let(:original_attribs) { { slug: slug, attrib1: 'original' } }
        let(:result) { obj.update slug, updated_attribs }
        let(:slug) { 'the-slug' }
        let(:updated_attribs) { { attrib1: 'updated' } }

        context 'for a valid update' do
          let(:record) do
            klass = Class.new do
              attr_accessor :attributes
              def initialize(attrs_in = {})
                @attributes = attrs_in
              end

              def update_attributes(updated_attribs = {})
                updated_attribs.each { |k, v| attributes[k] = v }
                true
              end
            end # class
            klass.new original_attribs
          end

          describe 'returns a StoreResult with' do
            it 'a #success? method returning true' do
              expect(result).to be_success
            end

            it 'an #entity method returning the updated entity' do
              expect(result.entity).to respond_to :attributes
              expect(result.entity.attributes).to respond_to :to_hash
              updated_attribs.each do |attrib, value|
                expect(result.entity.attributes[attrib]).to eq value
              end
            end

            it 'an #errors method returning an empty Array' do
              expect(result.errors).to respond_to :to_ary
              expect(result.errors).to be_empty
            end
          end # describe 'returns a StoreResult with'
        end # context 'for a valid update'

        context 'for a failed update' do
          let(:record) do
            klass = Class.new do
              attr_accessor :attributes
              def initialize(attrs_in = {})
                @attributes = attrs_in
              end

              def errors
                ActiveModel::Errors.new(self).tap do |e|
                  e.add :field1, 'is invalid'
                end
              end

              def update_attributes(_)
                false
              end
            end # class
            klass.new original_attribs
          end

          describe 'returns a StoreResult with' do
            it_behaves_like 'a failed StoreResult' # uses `result`
          end # describe 'returns a StoreResult with'
        end # context 'for a failed update'
      end # describe 'method #update'
    end # describe Newpoc::Repository::Base
  end # module Newpoc::Repository
end # module Newpoc
