# How Not To Write an API

## avoiding Unnecessary rabbit-holes

## Introduction

[typeahead.js](https://github.com/twitter/typeahead.js) renders a list of
suggested options below an input box as a user enters text:

![](http://i.imgur.com/swhWDDr.jpg)

You just need data and a DOM node to bind it to. This sounds easy, but the
talented maintainers have unwittingly created a very frustrating experience.

#### Remote Data

If your data is on a server, you can specify `url: /remote/%QUERY.json` where
`%QUERY` is replaced by the value of the input. That is, if you are running
`0.10.x`. In `0.11.x` you need to manually specify a `wildcard: "%QUERY"`
because although this option has the same syntax as the previous version, the
default wildcard is now null.

Once you pull the data down as an array of objects you can specify the key
with the handy `displayKey: objectKey` option. In versions prior to `0.11.0`
this content is inserted as HTML, whereas now it's in plaintext.

If you want to continue to do HTML insertion you may be thinking you can use
`display: function(){ … }` instead of the `displayKey`. This would make sense…

Instead, you ignore the `display` and `displayKey` options and write something
like

    
    
    {
      templates: {
        suggestion: function(row) { 
          // Return a JQuery node, because
          // that's all it will accept.
          return $("<p>")
            .html(row.html); 
        }
      }
    }

This gives you similar functionality to `displayKey` in `0.10.5`.

You'll probably want to do this since the inner DOM nodes in `0.11.x` have
changed from `<p>` tags to `<div>` tags. Oh, that brings us to style.

#### Stylizing

You'd think that being explicitly referenced in the Bootstrap documentation as
a supported library (in
[2.3.2](http://getbootstrap.com/2.3.2/javascript.html#typeahead) but not
3.x1), `typeahead.js` would structure their HTML as a Bootstrap-friendly style
drop-down…

> Note from 2015-06-16: This history isn't correct. [Chris Rebert
explains](https://github.com/kristopolous/articles/issues/1):

>

> To dispel a key misconception here: The similarity of the names is indeed
unfortunate & confusing, but Twitter's Typeahead.js is completely separate
from and has never shared any code with Bootstrap v2's typeahead widget. I
imagine that the fact that old versions of Twitter's Typeahead.js offered
optional Bootstrap integration also contributed to this confusion.

>

> In Bootstrap v3, Bootstrap's own typeahead widget from v2 was removed due to
its complexity and its suffering from some significant bugs. The Bootstrap
Core Team recommended that users migrate to Twitter's Typeahead.js since it
was a superior alternative (see http://getbootstrap.com/migration/#notes), and
since there was hope that Twitter's Typeahead.js would continue to offer an
optional Bootstrap integration (which sadly didn't pan out).

>

> With the release of version 3, Bootstrap ceased to be affiliated with
Twitter (see twbs/bootstrap#9899), which makes Typeahead.js's lack of
integration/compatibility with Bootstrap more understandable.

In Bootstrap 3, the [selectors for the dropdown](https://github.com/twbs/boots
trap/blob/efe2023014ec90f35c0f722af6f3ec7a8eab720e/dist/css/bootstrap.css#L360
5) are `.dropdown-menu > li > a`. However, in `0.10.x` the dropdowns are `span
> div > p` and in `0.11.x`, it's `div > div > div`.

If you think typeahead.js will still work with Bootstrap through the
`[classNames` interface](https://github.com/twitter/typeahead.js/blob/master/d
oc/jquery_typeahead.md#class-names) -- it doesn't and the object keys and
class names have changed [between the versions](https://github.com/twitter/typ
eahead.js/blob/v0.10.5/doc/jquery_typeahead.md#look-and-feel).

To make things display nicely, [you need a separate
stylesheet](https://github.com/bassjobsen/typeahead.js-bootstrap-css) that
inherits from Bootstrap's `less` source for `0.10.x` _and_ `0.11.x`.

#### Local data

If you have local data ... since typeahead has a `prefetch` and a `local`
option, you'd think you can just do a local search without specifying the
remote.

What actually happens is that an internal `this.query` parameter [doesn't get 
set](https://github.com/twitter/typeahead.js/blob/v0.10.5/src/typeahead/datase
t.js#L28), which determines the value of the input box on blur. Once you
navigate away from it, the value is cleared.3

There's an [undocumented `setQuery`](https://github.com/twitter/typeahead.js/b
lob/v0.11.1/src/typeahead/input.js#L213) you can use if you provide it with a
correctly wrapped object.2

But wait, you say, looking at the website, there's a simple example [provided
here](http://twitter.github.io/typeahead.js/examples/) with local data. [Look
at the gist](https://gist.github.com/jharding/9458744/revisions) and see
there's small differences between the two. These seem to be irrelevant and
stylistic. If you try the new code on the old version, you'll see that these
changes matter.

If you use the Bloodhound engine to provide an instance as a source, you can
in `0.9.x` and `0.11.x`. In `0.10.x` you use
`[instance.ttAdapter()`](https://gist.github.com/jharding/9458749/revisions).
You can see that in the example where they shadow a local variable they didn't
define.

#### Events

In `0.10.x` you can bind the node to a `[typehead:selected` event](https://git
hub.com/twitter/typeahead.js/blob/v0.10.5/doc/jquery_typeahead.md#custom-
events) (which [has been renamed](https://github.com/twitter/typeahead.js/blob
/v0.11.0/doc/jquery_typeahead.md#custom-events) to `typeahead:select` in
`0.11.0`). Now if you choose to do a `setQuery` inside the listener, you'll
get a `JQuery` error that is [thrown](https://github.com/twitter/typeahead.js/
blob/8d3e6de304486826ac47069cd2a2103c2f67897c/src/typeahead/dataset.js#L30) by
`typeahead`. You can avoid this by wrapping that in a `setTimeout` in the
renamed listener.

#### Compatibility

I'm glad this all makes sense. Especially since the [main
readme](https://github.com/twitter/typeahead.js#versioning) assures us: _New
additions _without_ breaking backwards compatibility bumps the minor_ They've
taken the time to provide a `0.9.x` -> `0.10.x` [migration guide](https://gith
ub.com/twitter/typeahead.js/blob/master/doc/migration/0.10.0.md) (there's
compatibility issues within the z versions of 0.10.x itself).

They should really just drop the first zero because that's what they actually
mean.

* * *

  1. Where it changed from Bootstrap-typeahead to typeahead.js.
  2. This was noted in [#577](https://github.com/twitter/typeahead.js/issues/577) and [#247](https://github.com/twitter/typeahead.js/issues/247) but never made its way to the documentation.
  3. At least for me.

## This isn't how you make an API

#### A release means you are ready to go

Everyone has bugs. If you are going to tag a version and make it a release,
you are telling the world that it's ready to go. The only person with the hand
on the release-trigger is the maintainer. If it's not ready, don't do it.

#### The developer is the end user. You are providing the user interface

When writing an API, you should refer to the programmers using it as "your
users" and the thing you provide as "your interface". All of the rules of
designing an intuitive consistent end product still apply when providing a
documented interface for fellow programmers.

#### Don't do things pre-emptively or frivolously

When designing something that people will use, you can either put things in
liberally and then have no qualms about breaking things a few weeks later, put
things in liberally and then feel the terrible burden of support, or create a
wall between supported (conservative) things and unsupported (liberal) things.

The last option is the only sensible one if you anticipate on supporting a
large number of users.

#### You are providing a tool

Developers are utilizing your tool to solve a problem, not deal with a bunch
of new ones presented by the presumptions or constraints of the technology.
There is no merit to providing a solution that takes just as long to implement
due to obtuse design then it would to do directly. You are effectively burning
your user base every time you do this.

The worst thing you can do is make your users think they've made a mistake
after sinking significant time and effort and then either holding their nose
as they try to just "make it work", or worse, abandon their efforts entirely
and think terrible thoughts about you.

## Conclusion

Nobody builds things to make enemies. We're in this to help people. We write
APIs for people to make better software -- not waste their time unraveling our
implementation to finish theirs. The whole point is to remove a problem, not
create new ones. Exhausting time, effort, and mind-share due to poor release
management is a terrible shame.

Their are real people behind every project and we must never forget that. It's
easy to remove the human from the experience and think evil malevolent
thoughts as you sip that third cup of coffee trying to get that thing done
that _should have been 15 seconds_.

We must do better.

