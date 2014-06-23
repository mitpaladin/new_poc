
require 'spec_helper'

describe ApplicationHelper::ExplainErrors do

  describe :explain_errors.to_s do

    # Dummy model class to use for testing `#explain_errors` method.
    class DummyModel
      include ActiveModel::Validations
      attr_accessor :throws
      validate :dummy_validator

      private

      def dummy_validator
        errors[:some_field] << 'is invalid because I say so.' if throws
      end
    end

    let(:model) { DummyModel.new }

    it 'generates no output when no errors known to the model' do
      expect(explain_errors model).to eq ''
    end

    describe 'generates output for errors' do

      it 'reported via ActiveModel::Validations' do
        model.throws = true
        expect(model).to_not be_valid  # needed to generate model.errors
        expected = '<div class="alert alert-danger" id="error_explanation">' \
          '<h2>1 error prevented this DummyModel from being saved:</h2>' \
          '<ul>' \
            '<li>Some field is invalid because I say so.</li>' \
          '</ul>' + '</div>'
        expect(explain_errors model).to eq expected
      end

      it 'reported via ActiveInteractions error reporting' do

        # Dummy ActiveInteractions command used to demonstrate error handling.
        class DummyCommand < ActiveInteraction::Base
          string :title # no default, therefore non-optional (required)

          def execute
            true
          end
        end

        expected = '<div class="alert alert-danger" id="error_explanation">' \
            '<h2>1 error prevented this DummyCommand from being saved:' \
            '</h2><ul><li>Title is required</li></ul></div>'
        result = DummyCommand.run
        expect(explain_errors result).to eq expected
      end
    end # describe 'generates output for errors'
  end # describe :explain_errors

end # describe ApplicationHelper::ExplainErrors
