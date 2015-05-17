
require 'spec_helper'

describe PostsController::Action::Create::PostDataFilter do
  describe 'has initialisation that' do
    it 'requires one parameter' do
      message = 'wrong number of arguments (0 for 1)'
      expect { described_class.new }.to raise_error ArgumentError, message
    end

    describe 'fails when given a parameter that is invalid because' do
      it 'is not sufficiently Hash-like' do
        param = 'bogus'
        expect { described_class.new param }.to violate_a_param_contract
          .with_arg(param)
          .identified_by(Hash)
          .returning(described_class)
      end
    end # describe 'fails when given a parameter that is invalid because'

    describe 'succeeds when given a parameter that is' do
      # FIXME: Should be Post data here...
      it 'an empty Hash' do
        expect { described_class.new({}) }.not_to raise_error
      end
    end # describe 'succeeds when given a parameter that is'
  end # describe 'has initialisation that'

  describe 'has a #filter method that' do
    it 'returns an OpenStruct instance' do
      expect(described_class.new({}).filter).to be_an OpenStruct
    end

    describe 'returns an OpenStruct with' do
      describe 'no attributes when initialised with' do
        let(:expected) { OpenStruct.new }

        after :each do
          expect(described_class.new(@param).filter).to eq expected
        end

        it 'an empty Hash' do
          @param = {}
        end

        it 'a Hash with only invalid attributes for a PostDao instance' do
          @param = { foo: 'bar', baz: { meaning: 42 } }
        end
      end # describe 'no attributes when initialised with'

      desc = 'all attributes when initialised with all valid attributes of a' \
        ' PostDao, including'
      describe desc do
        let(:actual) { described_class.new(param).filter }
        let(:expected) { OpenStruct.new param }
        let(:param) do
          FactoryGirl.attributes_for :post, :image_post, :saved_post,
                                     :published_post
        end

        it 'identical values for all attributes except :pubdate' do
          expected_keys = param.keys.reject { |k| k == :pubdate }.sort
          expected_keys.each do |attrib|
            expect(actual.send attrib).to eq expected.send(attrib)
            expect(actual.send attrib).to be_present
          end
        end

        # Mainly for CI
        it 'the :pubdate attribute within a small tolerance' do
          expect(actual.pubdate).to be_a String
          expect(expected.pubdate).to be_an ActiveSupport::TimeWithZone
          expect(Time.zone.parse actual.pubdate).to be_within(3.seconds)
            .of expected.pubdate
        end
      end # describe '...with all valid attributes of a PostDao, including'
    end # describe 'returns an OpenStruct with'
  end # describe 'has a #filter method that'
end
