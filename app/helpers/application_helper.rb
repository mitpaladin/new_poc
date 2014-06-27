
require 'application_helper/explain_errors'
require 'application_helper/show_appwide_flashes'

# Initially-empty shell for `ApplicationHelper` module. Will be added to as the
# app expands.
module ApplicationHelper
  include AppwideFlashes
  include ExplainErrors
end
