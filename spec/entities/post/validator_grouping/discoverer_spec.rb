
require 'spec_helper'

require 'post/validator_grouping/discoverer'

describe Entity::Post::ValidatorGrouping::Discoverer do
  let(:fixture) do
    module Foo
      class Bar
      end
      module Validators
        class Foo
        end
        class Bar
        end
        class Baz
        end
      end
    end
    Foo::Bar.new
  end
  let(:obj) { described_class.new fixture }
  let(:validator_syms) { Foo.const_get(:Validators).constants }

  describe 'can be initialised' do
    desc = 'with an instance of a namespaced class whose parent also includes' \
      ' a Validators namespace with classes in it'
    it desc do
      expect { described_class.new fixture }.not_to raise_error
    end
  end # describe 'can be initialised'

  describe 'has an #each method that' do
    desc =  'iterates the companion validators to the initialiser-specified' \
      ' class instance'
    describe desc do
      let(:actual) do
        {}.tap do |found|
          obj.each { |item| found[item.first] = item.last }
        end
      end
      it 'retrieving the correct number of entries' do
        expect(actual.count).to eq validator_syms.count
      end
      describe 'where each item is an Array that has' do
        it 'has two items' do
          obj.each do |item|
            expect(item).to respond_to :to_ary
            expect(item).to have(2).entries
          end
        end

        it 'has as the first item a lowercased symbol of the validator class' do
          actual.keys.each_with_index do |k, index|
            expect(k).to be validator_syms[index].to_s.downcase.to_sym
          end
        end

        it 'has a class as the last item' do
          actual.values.each { |v| expect(v).to be_a Class }
        end
      end # describe 'where each item is an Array that'
    end # describe 'iterates the companion validators ...'
  end # describe 'has an #each method that'

  describe 'has a :[] method that' do
    it 'returns a validator class given its corresponding symbolic index' do
      expect(obj[:foo]).to be Foo::Validators::Foo
    end

    it 'returns nil given an invalid index' do
      expect(obj[5]).to be nil
    end
  end # describe 'has a :[] method that'
end # describe Entity::Post::ValidatorGrouping::Discoverer
