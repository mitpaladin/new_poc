
# Shell for ApplicationHelper module. Used to reopen module.
module ApplicationHelper
  # Module containing `#explain_errors` method and support code exclusively
  # therefor.
  module ExplainErrors
    def explain_errors(model_obj)
      return '' unless model_obj.errors.any?

      explain_errors_for model_obj
    end

    private

    def attribs_for_error_container
      {
        class:  'alert alert-danger',
        id:     'error_explanation'
      }
    end

    def build_error_message_list(errors)
      message_array_for(errors).map { |m| content_tag :li, m }.join
    end

    def explain_errors_for(model_obj)
      message = format '%s prevented this %s from being saved:',
                       pluralize(model_obj.errors.count, 'error'),
                       model_obj.class.name
      list = build_error_message_list model_obj.errors
      content_tag(:div, attribs_for_error_container, false) do
        concat(content_tag :h2, message)
        concat(content_tag :ul, list, false, false)
      end
    end

    def message_array_for(error_obj)
      # #message_list is a method on Mutations::ErrorAtom. Oops.
      # if error_obj.respond_to? :message_list
      #   error_obj.message_list
      # else
      error_obj.full_messages
      # end
    end
  end # module ApplicationHelper::ExplainErrors
end # module ApplicationHelper
