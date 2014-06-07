# New POC

This is an experiment in clean(er) architecture in Rails. It's not intended as a full, releasable application, but rather to answer some critical questions about how we will actually release such an app.

## Background

It grew out of a year of experimentation with different techniques, such as [Draper](https://github.com/drapergem/draper) model decorators, various DSOs (domain-logic service objects, or "interactors") such as [ActiveInteraction](https://github.com/orgsync/active_interaction), [Mutations](https://github.com/cypriss/mutations), [`interactor`](https://github.com/collectiveidea/interactor) (not to be confused with the general term), and so on. Lots of people have recognised the pain points in Rails and come up with various pieces of a solution. Another technique proven useful is the use of [*message queues*](https://en.wikipedia.org/wiki/Message_queue) such as [Wisper](http://www.sitepoint.com/using-wisper-to-decompose-applications/) or [RabbitMQ](http://www.rabbitmq.com), itself built on the open [AMQP](https://en.wikipedia.org/wiki/Advanced_Message_Queuing_Protocol) standard.

These were driven by *multiple* incompletely successful attempts at a "traditional" Rails application, the issues with which I discuss somewhat [on my Tumblr](http://yeoldeprogrammer.tumblr.com/post/88061445570/rails-circular-logic-and-incremental-big-bang). There are components *used by* Rails that are absolutely brilliant (thank you, [ActiveModel](http://www.rubyinside.com/rails-3-0s-activemodel-how-to-give-ruby-classes-some-activerecord-magic-2937.html)), and others that, though clearly well-intentioned and amazingly useful in certain relatively narrow cases, have not aged well in the light of what we as a community now know about developing Web applications (I'm looking at *you*, [ActiveRecord](https://duckduckgo.com/?q=activerecord%20sucks)). If a million monkeys pecking randomly on typewriters for a million years will eventually produce the entire Shakespeare canon, then certainly one guy can get his (anatomy) on straight within a year or two on how a Rails-based app can survive and prosper in the post-2006 world?

So here we are.

## Overview

This *demo* will demonstrate a blog-style application built with tools and techniques previously shown as useful for isolating business domain logic ("what your app *does*") from the *initial* or *current* delivery system (Rails, [RubyMotion](http://www.rubymotion.com), a command-line app, a JSON API, smoke signals…who *cares?*). The initial delivery system will be a Web application built using Ruby 2.0+ and Rails 4.1+, currently Ruby `2.0.0p481` and Rails `4.1.2.rc1`, but those *should* be able to change relatively rely; in particular, the soon-to-be-released Rails 4.1.2 final should not affect the application.

Specific, significant components include:

* [Draper](https://github.com/drapergem/draper), for Rails model "decorators"; the Gem has also been described as providing ViewModels;
* [OrgSync ActiveInteraction](https://github.com/orgsync/active_interaction) as our DSO implementation mechanism;
* [Wisper](http://www.sitepoint.com/using-wisper-to-decompose-applications/) for decoupling services best thought of as orthogonal to either the "traditional" Rails MVC architecture or our DSO implementation;
* [Slim](http://slim-lang.com) as the view template language;
* and others that, though important in the development process, aren't really part of the point of the demo.

### What is this "success" you speak of?

This demo will be declared successful when it meets each and all of the following criteria, not listed in any sort of priority order:

1. Rails controllers, used to implement normal RESTful resource actions exhibit no direct knowledge of domain concepts; they defer to DSOs for actions upon data resources (such as "blog posts" or "user sessions") and page transitions (such as redirecting to a DSO-specified page on the success or failure o an action);
2. Rails views will have no domain-knowledge-exhibiting code embedded in them, but will call Rails helpers and/or Draper decorators. They should be as close to the often-discussed "logic-less templates" as is practicable;
3. The goals of the earlier `interactor_demo` tutorial adaptation shall be met, including:
	4. Logic analogous to the first twelve sections of Avdi Grimm's [*Objects on Rails*](http://objectsonrails.com) book, up to but *not including* persistence;
	5. Persistence, using standard ActiveRecord models shadowed by a boundary layer between ActiveRecord and the remainder of the domain logic;
	6. Authentication, allowing the author of each individual blog entry to be identified and credited when the article is presented;
	7. Authorisation, supporting three capabilities:
		8. Only the author of an article may edit its content after publication;
		9. When a user creates an article, it is initially marked as `draft` until explicitly published. While a post has `draft` status, only the author may view it or its title;
		10. An author may choose to publish an article as 'private', whereby it *will not* appear in index listings or the like. Any logged-in user who directly visits the post's URL, however, will be allowed to view its content;

Meeting each and all of these conditions will demonstrate that we have an application architecture that should be able to meet our needs not merely for the initial feature demonstration that has been promised, but going forward into a full application.

Code analysis and reporting tools, such as [`simplecov`](https://github.com/colszowka/simplecov) test-coverage reporting, [`rubocop`](http://batsov.com/rubocop/) style checking, [`metric_fu`](http://metricfu.github.io/metric_fu/old_index.html) metrics reporting, [`inch`](http://trivelop.de/inch/) documentation analysis, and so on, shall be used throughout the project to show where improvements may be worthwhile. This should be effected through an automated continuous-integration system such as [CruiseControl.rb](http://cruisecontrolrb.thoughtworks.com), which was the motivation for the project's `cruise` Rake task.

## How does this compare to the `interactor_demo` project?

[`interactor_demo`](https://github.com/jdickey/interactor_demo) is intended to compare and contrast different "interactors", or domain service objects (DSOs) which we might choose to use. This application makes use of *one* candidate for evaluation in that project, not as a "winner" of a competition, but simply as an example of how we would use such a component in a (slightly) less artificial environment than that project provides.

`interactor_demo`, largely for what are now historical reasons, is and will remain a Rails 3.2 app. This application is using Rails 4 (absent [turbolinks](http://blog.steveklabnik.com/posts/2013-06-25-removing-turbolinks-from-rails-4)) from its inception. One consequence of this is expected to be that the move from Rails 3.2 to Rails 4 should *not* affect how the DSOs or decorators are written and used, demonstrating even more conclusively that Rails is "just" an implementation detail.

Finally, this app is intended as a more complete demonstration of our application architecture than the earlier demo. By explicitly and consistently using DSOs, decorators, and message queues to isolate the domain logic from the implementation/delivery system, we demonstrate the ability to ramp up productivity from a severely under-resourced team while shifting into a more conventionally agile workflow with regular, incremental deliveries. This should not only dramatically improve morale within the company, it should be usable as a credible indication to outside stakeholders that we finally, at long last, have our "head on straight" and can be expected to significantly ramp up velocity towards delivering a successful product.

### Schedule Comparison

Whereas [`interactor_demo`](https://github.com/jdickey/interactor_demo) has taken several weeks of effort, plodding through its source material and incrementally (hopefully) improving the software and process used to create each successive candidate branch, this project builds on that earlier work for a straight-line, incremental, productive demonstration of its purpose. If the success criteria are not met by or very shortly after Monday 16 June 2014 at 2200 SGT (GMT+8), *Something* [has gone Horribly Wrong™](http://tvtropes.org/pmwiki/pmwiki.php/Main/GoneHorriblyWrong).

## Bugs and Feedback

If you discover a possible problem, please describe it (including your Ruby version, `Gemfile.lock`, `rbenv`/`dvm` setup, OS and version) in the issues tracker. Searching the issues tracker may allow you to take advantage of others' previous experience with problems similar to your own. Direct any questions to the maintainer to jeff.dickey@theprolog.com or jdickey@seven-sigma.com.

Patch requests submitted along with or following up on issue reports are greatly appreciated and will be responded to more quickly.

# License (New BSD)

Copyright (c) 2014 Jeff Dickey and Prolog Systems Pte Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.