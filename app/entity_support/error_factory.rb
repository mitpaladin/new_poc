
# Another *apparently* dirt-simple value class. Converts an Enumerable
# containing error field/message information to a an array of Hash instances.
#
# But, importantly, it's *not* the same Hash that calling `errors.to_json` would
# give you, at least not for a Rails `errors` object. Consider a case where two
# messages have been added to a (Rails) `errors` object:
#
#  # ...
#  errors.add :frobulator, "won't frob until later"
#  # ...
#  errors.add :frobulator, 'is busted'
#  # ...
#
# Calling `errors.messages` after that point would pass back a Hash,
#
#   {:frobulator=>["won't frob until later", "is busted"]}
#
# One key, with a value as an array of strings. (Importantly, even if there's
# only one string value for that key, the value is still wrapped in an array.)
#
# Calling `errors.to_json` at that point gives you back the string you'd expect
#
#   {"frobulator":["won't frob until later","is busted"]}
#
# But that's *not* what `ErrorFactory.create` would return. Instead, calling
# `ErrorFactory.create(errors)` with the example state of `errors` returns
#
#   [{:field=>:frobulator, :messsage=>"won't frob until later"}, \
#      {:field=>:frobulator, :messsage=>"is busted"}]
#
# (backslash and line wrap added for formatting here).
#
# Notice that the Hash with a string key and array value has been replaced by an
# array of as many hashes as needed to convey *each* key/value pair as its own
# Hash. On the one hand, it makes access to the contents of *any single* value
# Hash more uniform; the value will always be a single string, rather than an
# array of one or more strings. But the *reading* code needs to take care that
# the key of any particular Hash in the array may already exist in whatever data
# structure *it's* building, and so add subsequent messages to a container with
# a common key.
#
# It's all a question of how you want to handle it; at *some* point, multiple
# values for the same key will need to be stored in an Enumerable; should that
# be done on an in-app ad hoc basis or with the same array value that the
# original's JSON contains? So long as you're quite confident that the *vast*
# majority of cases will only have a single value per key, laziness would argue
# for the current approach. As soon as you start considering multiple values,
# edge-case determination and workaround logic in your code adds more work,
# defeating the originally virtuous laziness.
#
class ErrorFactory
  class << self
    def create(errors)
      errors.map do |field, message|
        { field: field.to_s, message: message }
      end
    end
  end
end
