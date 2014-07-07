
require 'spec_helper'

require 'post_data_decorator/body_builder'

# Support classes used by various Blog components; initially, helpers.
class PostDataDecorator
  # Internal support class(es) used by PostDataDecorator.
  module SupportClasses
    describe BodyBuilder do
      it 'accepts one parameter for initialisation' do
        expect { BodyBuilder.new h }.to_not raise_error
      end

      it 'stores the helper object in the instance variable :@h' do
        obj = BodyBuilder.new(h)
        expect(obj.instance_variable_get(:@h)).to be h
      end
    end
  end # module PostDataDecorator::SupportClasses
end # class PostDataDecorator
