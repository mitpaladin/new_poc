
require 'spec_helper'

require 'active_model/errors'

require 'newpoc/repository/internal/error_factory'

module Newpoc
  module Repository
    # Internal API not normally used from non-Repository code.
    module Internal
      describe ErrorFactory do
        describe :create.to_s do
          it 'returns an empty Array when an empty Errors object is supplied' do
            expect(described_class.create ActiveModel::Errors.new self).to eq []
          end

          describe 'returns an array of Hashes' do
            let(:message_pairs) do
              [
                { field1: 'message1' },
                { field1: 'message2' },
                { field2: 'message3' }
              ]
            end
            let(:errors) do
              e = ActiveModel::Errors.new self
              message_pairs.each do |entry|
                e.add entry.keys.first, entry.values.first
              end
              e
            end
            let(:actual) { described_class.create errors }

            it 'with one Hash for each message added' do
              expect(actual.count).to eq message_pairs.count
            end

            describe 'with each Hash having' do
              it 'one :field key and one :message key' do
                keys = [:field, :message]
                actual.each { |item| expect(item.keys).to eq keys }
              end

              it 'string-like values for both keys' do
                actual.each do |item|
                  item.values.each do |value|
                    expect(value).to respond_to :to_str
                  end
                end
              end
            end # describe 'with each Hash having'
          end # describe 'returns an array of Hashes'
        end # describe :create
      end # describe ErrorFactory
    end
  end
end
