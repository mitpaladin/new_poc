# `MelddRepository`

Contains a base class (`MelddRepository::Base`) for model Repository classes as developed for the [`new_poc`](https://github.com/jdickey/new_poc) exploration project, as well as an action-result-reporting class (`MelddRepository::StoreResult`).

## Installation

Add this line to your application's Gemfile when used as an externally-packaged Gem:

```ruby
gem 'meldd_repository'
```

The app this was originally developed for started out using it as an [unbuilt Rails dependency](http://pivotallabs.com/unbuilt-rails-dependencies-how-to-design-for-loosely-coupled-highly-cohesive-components-within-a-rails-application/); in that usage, the `Gemfile` line would read

```ruby
gem 'meldd_repository', path: 'lib/meldd-repository'
```

And then execute:

    $ bundle

This Gem **is not** envisioned as being used as a standalone, systemwide Gem; however, to install it as such, you would run the shell command:

    $ gem install meldd_repository

## Usage

### `MelddRepository::Base`

`MelddRepository::Base` is intended for use as a base class for other Repository classes aharing a great deal of common logic, as in the app for which it was originally developed. Repositories are used as a boundary layer for isolating database implementation details (using ActiveRecord, Sequel, or what-have-you) from client code (represented in the original app as "entities", e.g., `PostEntity` and `UserEntity`). The Repository classes corresponding to those entities (`PostRepository` and `UserRepository` respectively) in the original [monolithic app](https://github.com/jdickey/new_poc/tree/monolith-complete), as of that release tag, subclass the [immediate predecessor](https://github.com/jdickey/new_poc/blob/monolith-complete/app/repositories/repository_base.rb) of `MelddRepository::Base`.

It has/should have no external runtime dependencies beyond what is injected into the constructor. However, those constructor-injected dependencies are specific.

`MelddRepository::Base#initialize`'s first (of three) parameters is a Factory *class* which *must* have a class method named `create`. The factory's `create` method creates an instance of the *entity class* associated with a particular Repository subclass from the data contained within a single record from the DAO ([data-access object](http://en.wikipedia.org/wiki/Data_access_object)) which is *also* passed into `MelddRepository::Base#initialize`.

> **Note** that this class initially supports DAOs based on `ActiveRecord` models only. Support for other ORMs, prospectively [Sequel](http://sequel.jeremyevans.net/), is anticipated to be added at a later date.

The second parameter to `MelddRepository::Base#initialze` is the *class* of a DAO matching the entity class associated with a repository. For example, a hypothetical `CommentRepository` subclassed from `MelddRepository::Base` would probably have matching `CommentEntity` and `CommantDao` classes. `CommentDao`, as the data-access object, is the actual ORM class (such as an `ActiveRecord::Base` subclass) which is responsible *only* for persistence and database-integrity validations; it should be completely ignorant of business domain logic, unlike traditional Rails models.

The third parameter, which did not exist in the [predecessor class](https://github.com/jdickey/new_poc/blob/monolith-complete/app/repositories/repository_base.rb), is a Hash. It is **reserved for future use**.

Once an instance of a `MelddRepository::Base` subclass is created, it inherits the following instance methods:

| Method Name | Returns | Description |
|:----------- |:------- |:----------- |
| `add(entity)` | `MelddRepository::StoreResult` | Creates a new DAO record instance from the passed-in entity instance. Returns a new `MelddRepository::StoreResult` instance (see below) which indicates success or failure. Remember that the `entity` field within the result should be treated as an *updated* replacement for the original entity! |
| `all` | `Array` of entities | Returns an Array of entity instances created by calling the standard array method `#map` on the result from calling `#all` on the DAO class. |
| `find_by_slug(slug)` | `MelddRepository::StoreResult` | Searches for a DAO record identified by the specified `slug`, returning a `MelddRepository::StoreResult` indicating success or failure. Unlike the [predecessor]((https://github.com/jdickey/new_poc/blob/monolith-complete/app/repositories/repository_base.rb) class' method, the "success" result contains an entity instance, rather than a DAO record. (Oops.) |
| `update(identifier, updated_attrs)` | `MelddRepository::StoreResult` | Updates the DAO record identified by the slug passed in as `identifier` with attribute values from the Hash or Hash-like object passed in as `updated_attrs`. |

### `MelddRepository::StoreResult`

Instances of this class are returned from several `MelddRepository::Base` methods to report the success or failure of commanded actions. It is a value object with three public instance methods:

| Method Name | Returns | Description |
|:----------- |:------- |:----------- |
| `entity` | An entity instance or `nil` | After a successful Repository method call, this returns an instance of an entity class, such as was specified to the initialiser of `MelddRepository::Base`, reflecting any changes commanded by the method call. After an *unsucessful* Repository method call, this will return `nil`. |
| `errors` | `[]` or error-data array | After a successful Repository method call, this will return an empty Array. After an *unsuccessful* Repository method call, this will return an Array of Hash instances. Each Hash must have two keys, `:field` and `:message`. The value for `:field` will be a Repository-specific name, generally but not necessarily a field name such as `name`. The value for `:message` will be a Repository-specified message for a single error, not including the field name. Multiple errors associated with a single field will cause multiple Hash instances with the same `:field` value to be included in the returned Array. |
| `success?` | boolean | Returns `true` to indicate a successful result, or `false` to indicate a failure. |

## Contributing

1. As this is an inbuilt component of a larger application, presently you must for the entire application to work on this. Fork it from https://github.com/jdickey/new_poc/fork and find it (including specs) in the `lib/meldd_repository` directory.
1. Create your feature branch (`git checkout -b my-new-feature`)
1. Create your new code, or make changes to existing code. Ensure that specs cover all paths through code you touch. Also ensure that your code conforms to the [Ruby Style Guide](https://github.com/bbatsov/ruby-style-guide) as enforced by [RuboCop](https://github.com/bbatsov/rubocop) as bundled and configured by the parent application.
1. Commit your changes *and specs* to your feature branch using `git commit -a`. *Please* don't do single-line `git commit -am "..."` commits. The last two lines of your commit message should include the results *for the Gem* as reported by `rake` as of your new commit (e.g., `RSpec: 29 examples, 0 failures`) and then, on the next/final line, your RuboCop results (e.g., `9 files inspected, 0 offenses detected`). *Branches/PRs with nonzero values for Rubocop "offenses" will not be accepted.*
1. Push to the branch (`git push origin my-new-feature`). (If this is the first time you've pushed to your remote branch, remember to do `git push -u origin my-new-feature` instead.)
1. Create a new Pull Request. Pull requests not including full spec coverage of new/modified code, or with RuboCop failures *will not be accepted*.
