
require 'spec_helper'

require 'post_decorator/body_builder'

# Support classes used by various Blog components; initially, helpers.
class PostDecorator
  # Internal support class(es) used by PostDecorator.
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
  end # module PostDecorator::SupportClasses
end # class PostDecorator
