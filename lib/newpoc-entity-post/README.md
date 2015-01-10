# Newpoc::Entity::Post

Encapsulates the Post entity as used in the `jdickey/new_poc` technology demo project.

Major goals of that project is decoupling components where it makes sense, and isolating business/domain logic (such as encapsulated in entities like `PostEntity`) from changes in implementation-level code (such as a containing Rails app). Hence, this.

## Installation

This was initially developed with the expectation that it would be used as an [unbuilt dependency](http://pivotallabs.com/unbuilt-rails-dependencies-how-to-design-for-loosely-coupled-highly-cohesive-components-within-a-rails-application/) of a larger project. To use it in that context, add this line to your application's Gemfile:

```ruby
gem 'newpoc-entity-post', path: 'some/path/to/newpoc-entity-post'
```

(where `some/path/to` will usually be `lib`). If this has been packaged into an ordinary Gem, of course, you'd install it as any other, by adding this line to your application's Gemfile:

```ruby
gem 'newpoc-entity-post'
```

And then execute:

    $ bundle

You probably would never do this for *this* particular code, but you could install a standalone Gem systemwide as:

    $ gem install newpoc-entity-post

## Usage

As noted above, this encapsulates the Post entity used in the `jdickey/new_poc` project. As such, it replaces the previously standalone `PostEntity` with the class to be found at `Newpoc::Entity::Post`. This encapsulates high-level, business/domain logic independently of persistence, presentation or other implementation-level concerns. See the usage in the demo app for examples.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/newpoc-entity-post/fork )
1. Create your feature branch (`git checkout -b my-new-feature`)
1. Ensure that your changes are completely covered by *passing* specs, and comply with the [Ruby Style Guide](https://github.com/bbatsov/ruby-style-guide) as enforced by [RuboCop](https://github.com/bbatsov/rubocop). To verify this, run `bundle exec rake`, noting and repairing any lapses in coverage or style violations;
1. Commit your changes (`git commit -a`). Please *do not* use a single-line commit message (`git commit -am "some message"`). A good commit message notes what was changed and why in sufficient detail that a relative newcomer to the code can understand your reasoning and your code;
1. Push to the branch (`git push origin my-new-feature`)
1. Create a new Pull Request. Describe at some length the rationale for your new feature; your implementation strategy at a higher level than each individual commit message; anything future maintainers should be aware of; and so on. *If this is a modification to existing code, reference the open issue being addressed*.
1. Don't be discouraged if the PR generates a discussion that leads to further refinement of your PR through additional commits. These should *generally* be discussed in comments on the PR itself; discussion in the Gitter room (see below) may also be useful;
1. If you've comments, questions, or just want to talk through your ideas, don't hesitate to hang out in the project's [room on Gitter](https://gitter.im/jdickey/new_poc). Ask away!
