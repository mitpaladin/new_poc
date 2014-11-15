# New POC

[![Code Climate](https://codeclimate.com/github/jdickey/new_poc.png)](https://codeclimate.com/github/jdickey/new_poc)

This is an experiment in clean(er) architecture in Rails. It's not intended as a full, releasable application, but rather to answer some critical questions about how we will actually release such an app.

## Background

It grew out of a year of experimentation with different techniques, such as [Draper](https://github.com/drapergem/draper) model decorators, various DSOs (domain-logic service objects, or "interactors") such as [ActiveInteraction](https://github.com/orgsync/active_interaction), [Mutations](https://github.com/cypriss/mutations), [`interactor`](https://github.com/collectiveidea/interactor) (not to be confused with the general term), and so on. Lots of people have recognised the pain points in Rails and come up with various pieces of a solution. Another technique proven useful is the use of [*message queues*](https://en.wikipedia.org/wiki/Message_queue) such as [Wisper](http://www.sitepoint.com/using-wisper-to-decompose-applications/) or [RabbitMQ](http://www.rabbitmq.com), itself built on the open [AMQP](https://en.wikipedia.org/wiki/Advanced_Message_Queuing_Protocol) standard.

These were driven by *multiple* incompletely successful attempts at a "traditional" Rails application, the issues with which I discuss somewhat [on my Tumblr](http://yeoldeprogrammer.tumblr.com/post/88061445570/rails-circular-logic-and-incremental-big-bang). There are components *used by* Rails that are absolutely brilliant (thank you, [ActiveModel](http://www.rubyinside.com/rails-3-0s-activemodel-how-to-give-ruby-classes-some-activerecord-magic-2937.html)), and others that, though clearly well-intentioned and amazingly useful in certain relatively narrow cases, have not aged well in the light of what we as a community now know about developing Web applications (I'm looking at *you*, [ActiveRecord](https://duckduckgo.com/?q=activerecord%20sucks)). If a million monkeys pecking randomly on typewriters for a million years will eventually produce the entire Shakespeare canon, then certainly one guy can get his (anatomy) on straight within a year or two on how a Rails-based app can survive and prosper in the post-2006 world?

So here we are.

## Overview

This *demo* will demonstrate a blog-style application built with tools and techniques previously shown as useful for isolating business domain logic ("what your app *does*") from the *initial* or *current* delivery system (Rails, [RubyMotion](http://www.rubymotion.com), a command-line app, a JSON API, smoke signals…who *cares?*). The initial delivery system will be a Web application built using Ruby 2.0+ and Rails 4.1+, currently Ruby `2.0.0p481` and Rails `4.1.2.rc1`, but those *should* be able to change relatively rely; in particular, the soon-to-be-released Rails 4.1.2 final should not affect the application.

Specific, significant components include:

* Usage of Rails models as data-access objects, or DAOs, to isolate ActiveRecord from the rest of the app *per se*. This was *heavily* inspired by [Eno Compton](https://github.com/enocom) (["Commander Coriander"](http://commandercoriander.net/blog/))'s blog post on [*Isolating ActiveRecord*](http://commandercoriander.net/blog/2014/10/02/isolating-active-record/) and its accompanying [Github repo](https://github.com/enocom/json-api/tree/control-flow-repo);
* [FriendlyId](https://github.com/norman/friendly_id) for [*slugging*](http://en.wikipedia.org/wiki/Semantic_URL#Slug). Instead of using the typical numeric IDs for posts and users, including in their ([RESTful](http://en.wikipedia.org/wiki/Representational_state_transfer) URLs such as `/posts/47129`), (more) meaningful text strings are used (such as, e.g., `/posts/the-next-great-idea`);
* [Slim](http://slim-lang.com) as the view template language. This was the simplest Rails-compatible view-template system known to me at the time the project started;
* and others that, though important in the development process, aren't really part of the point of the demo.

What we're *no longer* using:

* `ActiveInteraction` for DSOs. It's brilliant, and works very well *if* your app is "close enough" to The Rails Way to use `ActiveRecord::Base`, or at least `ActiveModel`. We're no longer doing so, we're using simple command-pattern POROs that *selectively* mix in ActiveModel support as needed (via [ActiveAttr](https://github.com/cgriego/active_attr));
* [Draper](https://github.com/drapergem/draper), for Rails model "decorators"; the Gem has also been described as providing ViewModels. We're not interacting directly with Rails models in our view (or helper) code now that we've gone through the process of isolating ActiveRecord (see above) so this too, while awesome at what it does, isn't something we use any more.


### What is this "success" you speak of?

This demo will be declared successful when it meets each and all of the following criteria, not listed in any sort of priority order:

1. Rails controllers, used to implement normal RESTful resource actions exhibit no direct knowledge of domain concepts; they defer to DSOs for actions upon data resources (such as "blog posts" or "user sessions") and page transitions (such as redirecting to a DSO-specified page on the success or failure o an action);
2. Rails views will have no domain-knowledge-exhibiting code embedded in them, but will call Rails helpers and/or domain-entity methods. They should be as close to the often-discussed "logic-less templates" as is practicable;
3. The goals of the earlier `interactor_demo` tutorial adaptation shall be met, including:
	4. Logic *roughly* analogous to the first thirteen sections of Avdi Grimm's [*Objects on Rails*](http://objectsonrails.com/) book, **but** see the section "*It Seemed a Good Idea at the Time*" [below](#it-seemed-a-good-idea-at-the-time);
	5. Persistence, using standard ActiveRecord models shadowed by a boundary layer between ActiveRecord and the remainder of the domain logic;
	6. Authentication, allowing the author of each individual blog entry to be identified and credited when the article is presented;
	7. Authorisation, supporting three capabilities:
		8. Only the author of an article may edit its content;
		9. When a user creates an article, it is initially marked as `draft` until explicitly published. While a post has `draft` status, only the author may view it or its title;
		10. An author may choose to publish an article as 'private', whereby it *will not* appear in index listings or the like. Any logged-in user who directly visits the post's URL, however, will be allowed to view its content;

Meeting each and all of these conditions will demonstrate that we have an application architecture that should be able to meet our needs not merely for the initial feature demonstration that has been promised, but going forward into a full application.

Code analysis and reporting tools, such as [`simplecov`](https://github.com/colszowka/simplecov) test-coverage reporting, [`rubocop`](http://batsov.com/rubocop/) style checking, [`metric_fu`](http://metricfu.github.io/metric_fu/old_index.html) metrics reporting, [`inch`](http://trivelop.de/inch/) documentation analysis, and so on, shall be used throughout the project to show where improvements may be worthwhile. This should be effected through an automated continuous-integration system such as [CruiseControl.rb](http://cruisecontrolrb.thoughtworks.com), which was the motivation for the project's `cruise` Rake task.

### It Seemed a Good Idea at the Time…

…has been the start of many a tale of attempted expedience yielding (hopefully) useful experience. Here, as well. As mentioned elsewhere, in my view, Avdi's *Objects on Rails* sample app implementation, and in fact even some of the techniques, have not aged particularly well as Rails has gone from the version 3.0 that was current as the book was written, to version 3.2 as we had used until quite recently, to version 4.1 which is current as I write this. Many things have changed along the way, as one might expect between major versions. One that has bitten us in particular is the ease of creating app-wide globals in Rails 3 vs Rails 4. My *impressions* at this stage are that Rails 4 actively and deliberately make it harder to have data shared across controllers that is neither persisted nor part of session storage, as opposed to Rails 3, which by letting one put just about anything into an initialiser loaded at application startup from the `config/initializers` directory, allowed the technique that Avdi cleverly used in the section entitled "[Making the Blog object into a Singleton](http://objectsonrails.com/#sec-6_3)". Rails appears to offer its own mechanism for singleton resources, as does Ruby with its Singleton module, but neither support the casual "here's a global object that *oh, by the way* is just an instance of a normal model that has non-singleton instances running about".

Additionally, at least at the time that he wrote this book, Avdi was firmly in the "mockist" TDD camp; my experience of the last few months in particular has placed me ever more firmly in the ["classical"](http://martinfowler.com/articles/mocksArentStubs.html) camp. I *need* to have a green bar in order to continue onto the next thing; and I'm *far* more confident working with actual code artefacts than with mocks that may or may not reflect the current state of the artefacts they represent. A *significant* part of the work in *Objects on Rails* is spent building up mock objects for code that doesn't exist yet. While this makes initial implementation (arguably) easier by decoupling the order of implementation from the dependency tree, *understanding* those dependencies, and the impact of changing them, tends to make maintenance and enhancement less prone to embarrassing errors. For example, it has not been at all uncommon to have all specs up to a given point passing (using a mixture of mocks and live code) to a point where one would expect things to Just Work, only to be presented with an application failure when opening the app in a browser. Eliminating [mocks](http://martinfowler.com/articles/mocksArentStubs.html) mocks makes that, if not less likely, at least more readily diagnosed and repaired.

Finally, *Objects on Rails* was a book about better application design *while remaining firmly rooted in the traditional Rails architecture and application structure*. We have now roamed far afield from there, isolating ActiveRecord models as simple DAOs and using domain entities and repositories to complete the [Data Mapper *pattern*](http://martinfowler.com/eaaCatalog/dataMapper.html). We believe this to be more understandable, maintainable, scaleable and flexible than Rails' (arguable) misinterpretation of Fowler's [Active Record](http://martinfowler.com/eaaCatalog/activeRecord.html) pattern.

#### Recovery

*Given all of the above*, we're going to depart from a formalistic progression through the steps in the book, using the following principles:

1. The whole *point* of this project was originally to demonstrate  an alternate, "cleaner" Rails application architecture, making heavy use of domain-logic service objects (DSOs) to demonstrate a more [decoupled](https://www.youtube.com/watch?v=tg5RFeSfBM4), [hexagonal](https://duckduckgo.com/?q=hexagonal+rails+architecture)-style Rails application architecture, separating the delivery mechanism (Rails) from domain logic (the DSOs and associated [PORO](http://blog.jayfields.com/2007/10/ruby-poro.html)s). Initially, we sought to leverage that, including using our (at any given time) current understanding of our persistence needs to implement Rails models and [boundary objects](http://blog.8thlight.com/uncle-bob/2012/08/13/the-clean-architecture.html) to back our DSOs. We still use DSOs, but persistence is now handled via a repository layer using the Data Mapper pattern.
2. We started the project, following Avdi's book, without persistence, introducing it at a point corresponding to the start of section 5.6, [*Adding entries to the blog*](http://objectsonrails.com/#sec-5_6); he has a `Post` class defined that supports useful work such as the end result of that section, actually adding "placeholder" entries to the blog (which he first talked about back in [section 5.1](objectsonrails.com/#sec-5_1)). Again, that continued until we started work on isolating ActiveRecord models using a very different mechanism.
3. By choosing that point of divergence, rather than, say, where he [defines his initial `Post` class](objectsonrails.com/#sec-5_4), we defer the full-on persistence model as late as we reasonably can given our current approach; deferring decisions as late as possible has been cited as a sign of [good](http://blog.8thlight.com/uncle-bob/2011/11/22/Clean-Architecture.html) [architecture](http://www.ben-morris.com/lean-developments-last-responsible-moment-should-address-uncertainty-not-justify-procrastination) and [good practice](http://www.codingthearchitecture.com/2011/11/06/the_delivery_mechanism_is_an_annoying_detail.html).
4. This will eliminate entire sections of the book as not relevant to our implementation, including the "make the Blog instance a singleton" to begin with, along with his "figleaf" for ActiveRecord (corresponding to the boundary objects our DSOs use to "talk" to the (ActiveRecord-based) Rails models, and so on. Some of that elimination was already at least implicit in our use of DSOs rather than embedded controller/helper code, but this directional rupture makes the omissions even more apparent.
5. Over the course of the project, the work involved in *replacing* what was originally done following the Book, and then striking out in a significantly different direction, involved a far greater level and duration of effort than was foreseen at project inception. This is both a valuable lesson and a cautionary tale: even if a team is using a strongly agile process, it is far better to *either* make and keep to a decision on basic architecture from the beginning *or*, as we now actually recommend, developing the application in as small, independent units as practical (using Gems; Rails engines; separate, not necessarily Rails-based applications; and the like).)

## How does this compare to the `interactor_demo` project?

[`interactor_demo`](https://github.com/jdickey/interactor_demo) is intended to compare and contrast different "interactors", or domain service objects (DSOs) which we might choose to use. This application makes use of *one* candidate for evaluation in that project, not as a "winner" of a competition, but simply as an example of how we would use such a component in a (slightly) less artificial environment than that project provides.

`interactor_demo`, largely for what are now historical reasons, is and will remain a Rails 3.2 app. This application is using Rails 4 (absent [turbolinks](http://blog.steveklabnik.com/posts/2013-06-25-removing-turbolinks-from-rails-4)) from its inception. One consequence of this is expected to be that the move from Rails 3.2 to Rails 4 should *not* affect how the DSOs or decorators are written and used, demonstrating even more conclusively that Rails is "just" an implementation detail.

Finally, this app is intended as a more complete demonstration of our application architecture than the earlier demo. By explicitly and consistently using DSOs, decorators, and message queues to isolate the domain logic from the implementation/delivery system, we demonstrate the ability to ramp up productivity from a severely under-resourced team while shifting into a more conventionally agile workflow with regular, incremental deliveries. This should not only dramatically improve morale within the company, it should be usable as a credible indication to outside stakeholders that we finally, at long last, have our "head on straight" and can be expected to significantly ramp up velocity towards delivering a successful product.

## Bugs and Feedback

If you discover a possible problem, please describe it (including your Ruby version, `Gemfile.lock`, `rbenv`/`dvm` setup, OS and version) in the issues tracker. Searching the issues tracker may allow you to take advantage of others' previous experience with problems similar to your own. Direct any questions to the maintainer to jeff.dickey@theprolog.com or jdickey@seven-sigma.com.

If you think I'm starting off in a reasonable direction but going into the weeds at some point, show me! Fork the project, create a new branch at the last point before what you see as my serious error, and show how *you* would have done it differently. The more we discuss this as a professional community, the more we can learn from each other and each improve our work.

Pull requests submitted along with or following up on issue reports are greatly appreciated and will be responded to more quickly.

*NEW!* We're also available on [Gitter](https://gitter.im), in the [`jdickey/new_poc`](https://gitter.im/jdickey/new_poc) room!

# License (New BSD)

Copyright (c) 2014 Jeff Dickey and Prolog Systems Pte Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
