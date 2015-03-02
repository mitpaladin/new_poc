
# Newpoc::Action::Post::Update

Encapsulates the use case (domain/business logic processing) for acquiring a
Post entity instance to use as the basis for updating if all presented
information is consistent with domain rules. If those conditions are not met,
information describing the error is instead broadcast.

Presently, broadcasts a [Wisper](https://github.com/krisleech/wisper) event,
defaulting to `:success`, with a payload consisting of a Post entity instance if
the specified post exists and is authored by the currently logged-in user. A
different event, defaulting to `:failure`, is broadcast if either of those
checks fail.

## Installation

This was initially developed with the expectation that it would be used as an
[unbuilt dependency](http://pivotallabs.com/unbuilt-rails-dependencies-how-to-design-for-loosely-coupled-highly-cohesive-components-within-a-rails-application/)
of a larger project. To use it in that context, add this line to your
application's Gemfile:

```ruby
gem 'newpoc-action-post-update', path: 'some/path/to/newpoc-action-post-update'
```

(where `some/path/to` will usually be `lib`). If this has been packaged into an
ordinary Gem, of course, you'd install it as any other, by adding this line to
your application's Gemfile:

```ruby
gem 'newpoc-action-post-update'
```

And then execute:

    $ bundle

You probably would never do this for *this* particular code, but you could
install a standalone Gem systemwide as:

    $ gem install newpoc-action-post-update

## Usage

In a Rails app such as [`new_poc`](https://github.com/jdickey/new_poc), you'd
have an `#update` method in your `PostssController` that looked something like:

```ruby
  def update
    guest_user = UserRepository.new.guest_user.entity
    action = Newpoc::Action::Post::Update.new(params[:id], current_user, PostRepository.new, guest_user, :success)
    action.subscribe(self, prefix: :on_update).execute
  end
```

(Note the usage of the singular in `Action` and `Post` namespace names.)

This would wire up the `action` to broadcast the `:success` event on successful
completion of the action, directing it to be received by the `#on_update_success`
method of this controller. (See the [`wisper`](https://github.com/krisleech/wisper)
documentation for background on events and handlers). The `:success` parameter
to `#new` is redundant as it is the default.

## Contributing


1. Fork the main app ( https://github.com/jdickey/new_poc/fork )
1. Create your feature branch (`git checkout -b my-new-feature`)
1. Ensure that your changes are completely covered by *passing* specs, and comply with the [Ruby Style Guide](https://github.com/bbatsov/ruby-style-guide) as enforced by [RuboCop](https://github.com/bbatsov/rubocop). To verify this, run `bundle exec rake`, noting and repairing any lapses in coverage or style violations;
1. Commit your changes (`git commit -a`). Please *do not* use a single-line commit message (`git commit -am "some message"`). A good commit message notes what was changed and why in sufficient detail that a relative newcomer to the code can understand your reasoning and your code;
1. Push to the branch (`git push origin my-new-feature`)
1. Create a new Pull Request. Describe at some length the rationale for your new feature; your implementation strategy at a higher level than each individual commit message; anything future maintainers should be aware of; and so on. *If this is a modification to existing code, reference the open issue being addressed*.
1. Don't be discouraged if the PR generates a discussion that leads to further refinement of your PR through additional commits. These should *generally* be discussed in comments on the PR itself; discussion in the Gitter room (see below) may also be useful;
1. If you've comments, questions, or just want to talk through your ideas, don't hesitate to hang out in the project's [room on Gitter](https://gitter.im/jdickey/new_poc). Ask away!