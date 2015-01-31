# Newpoc::Action::Session::Destroy

Encapsulates the  use case (business/domain logic processing) for destroying a
user session (logging the user out). If we wanted to reassure ourselves that the
Guest User wasn't trying to log out, or if we wanted to maintain a "last logged
out at" timestamp on the user entity (and we passed the logging-out user into
this action), this would be the place to do it. 

For now, all logic is supporting-implementation dependent with no domain logic,
so this is a (rather ornate) no-op.

## Installation

This was initially developed with the expectation that it would be used as an
[unbuilt dependency](http://pivotallabs.com/unbuilt-rails-dependencies-how-to-design-for-loosely-coupled-highly-cohesive-components-within-a-rails-application/)
of a larger project. To use it in that context, add this line to your
application's Gemfile:

```ruby
gem 'newpoc-action-session-destroy', path: 'some/path/to/newpoc-action-session-destroy'
```

(where `some/path/to` will usually be `lib`). If this has been packaged into an
ordinary Gem, of course, you'd install it as any other, by adding this line to
your application's Gemfile:

```ruby
gem 'newpoc-action-session-destroy'
```

And then execute:

    $ bundle

You probably would never do this for *this* particular code, but you could
install a standalone Gem systemwide as:

    $ gem install newpoc-action-session-destroy

## Usage

In a Rails app such as [`new_poc`](https://github.com/jdickey/new_poc), you'd
have a `#destroy` method in your `SessionsController` that looked something like:

```ruby
  def destroy
    Action::DestroySession.new.subscribe(self, prefix: :on_destroy).execute
  end
```

(Note the usage of the singular in `Action` and `Session` namespace names.)

This would wire up the `action` to broadcast the `:success` event on successful
completion of the action, directing it to be received by the
`#on_destroy_success` method of this controller. (See the
[`wisper`](https://github.com/krisleech/wisper) documentation for background on
events and handlers).

## Contributing

1. Fork the main app ( https://github.com/jdickey/new_poc/fork )
1. Create your feature branch (`git checkout -b my-new-feature`)
1. Ensure that your changes are completely covered by *passing* specs, and comply with the [Ruby Style Guide](https://github.com/bbatsov/ruby-style-guide) as enforced by [RuboCop](https://github.com/bbatsov/rubocop). To verify this, run `bundle exec rake`, noting and repairing any lapses in coverage or style violations;
1. Commit your changes (`git commit -a`). Please *do not* use a single-line commit message (`git commit -am "some message"`). A good commit message notes what was changed and why in sufficient detail that a relative newcomer to the code can understand your reasoning and your code;
1. Push to the branch (`git push origin my-new-feature`)
1. Create a new Pull Request. Describe at some length the rationale for your new feature; your implementation strategy at a higher level than each individual commit message; anything future maintainers should be aware of; and so on. *If this is a modification to existing code, reference the open issue being addressed*.
1. Don't be discouraged if the PR generates a discussion that leads to further refinement of your PR through additional commits. These should *generally* be discussed in comments on the PR itself; discussion in the Gitter room (see below) may also be useful;
1. If you've comments, questions, or just want to talk through your ideas, don't hesitate to hang out in the project's [room on Gitter](https://gitter.im/jdickey/new_poc). Ask away!
