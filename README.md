# cempl
Javascript functional templating/generator engine, best in use with Coffee-Script. Should be portable to work in the browser.

It’s more of a generatorr, since it doesn’t parse the template - It executes it. 

It's all written in Coffee-Script, but the NPM is pre compiled and depends only on lodash.

# Why

Because template engines is cumbersome when it comes to reuse components, especially small components. Also, I like functional programming. 

For instance, in cempl you can define a tag for each bootstrap construct that you wish. Even if it’s just a div with a class such as.

``` html
<div class=”col-md-12”>
```
Can look like
``` coffeescript
@col_md_12
```

Let’s see how.

# Installation

``` bash
npm install --save cempl
```

# Usage

## Where do I put it
Say you are building a site with express.js. You would normally in your controller execute res.render(‘myview’, {}).

With cempl you would instead do res.end(myview().eval()) because res.end() takes a string that it sends over to the client, and cempl.eval() generates a string from a generator function.

## Show me the real stuff
Let’s start with whatever all other templating engines can also provide.

### Basic componentisation
Start with require and create a document.

``` coffeescript
cempl = require(‘cempl’)

document = cempl ->
```

Evaluating this won’t give you much, but from here you can start build your page.

``` coffeescript
myGenerator = () ->
  cempl ->
    @doctype() # defaults to html 5 doctype
    @head ->
      @title “My site”
    @body ->
      @div ->
        @p “Hello world”

res.end(myGenerator().eval())
```

This looks like a typical HTML Hello World page. Can we find any typically repetitive code in here? I suspect that @doctype, @head with @title and @body with the first @div is typically repetitive. So we wish to put those parts in a reusable component. This can be done in a couple of different ways. Let me show you two.

``` coffeescript
document = (title) ->
  @doctype() # defaults to html 5 doctype
  @head ->
    @title title
  @body ->
    @div ->

myGenerator = (title, message) ->
  cempl ->
    @apply ‘layout’, title ->
      @p message

res.end(myGenerator(“My Title”, “Hello world”).eval())
```

This construction opinionates the typical “view first - layout secondary” point of view. Sort of how Jade works. Since all of this is just functions that is passed around to other functions, we can turn this inside out like below.


``` coffeescript
myLayout = (title, content) ->
  cempl ->
    @doctype() # defaults to html 5 doctype
    @head ->
      @title title
    @body ->
      @div ->
        @apply content

res.end(myLayout(“My title”, () -> 
  @p “Hello World”
).eval())
```

As you see, depending what you want to accomplish, there are different approaches. My opinion about the matter is that you should chose path based on how the using of the component will be done. Remember, any component can include any sub components in any depth you need.

### Creating tags
So now you know how to @apply components to generators. Let’s see if we can take this one step further by creating shorthand solutions for repetitive code. We take bootstrap as an example and we skip the header and other wrapper stuff and go straight for the money.

``` coffeescript
myGenerator = (title, message) ->
  cempl ->
    @register ‘container’, (content) -> @div class:’container’, content
    @register ‘row’, (content) -> @div class:’row’, content

    _.forEach([1,2,3,4,5,6,7,8,9,10,11,12], (num) ->
      @register "col_md_#{num}", (content) -> @div class:’col-md-#{num}’, content)

    @apply ‘layout’, title ->
      # We are now in the body tag
      @container ->
        @row ->
          @col_md_6 ->
            @p “This is a left side text”
          @col_md_6 ->
            @p “This is a right side text”

res.end(myGenerator(“My Title”, “Hello world”).eval())
```

Of course, you could put all @register in a component that you could apply to your generator. So that you can use your bootstrap tags in any generator you wish.

## Reference


### Built in tags: 

```
  'DOCTYPE', 'a', 'abbr', 'acronym', 'efines ', 'address', 'applet',
  'efines ', 'area', 'article', 'aside', 'audio', 'b', 'base', 'basefont',
  'pecifies ', 'bdi', 'bdo', 'big', 'efines ', 'blockquote', 'body', 'br',
  'button', 'canvas', 'caption', 'center', 'efines ', 'cite', 'code',
  'col', 'colgroup', 'datalist', 'dd', 'del', 'details', 'dfn', 'dialog',
  'dir', 'efines ', 'div', 'dl', 'dt', 'em', 'embed', 'fieldset',
  'figcaption', 'figure', 'font', 'efines ', 'footer', 'form', 'frame',
  'efines ', 'frameset', 'efines ',  'head', 'header', 'hr', 'html',
  'i', 'iframe', 'img', 'input', 'ins', 'kbd', 'keygen', 'label',
  'legend', 'li', 'link', 'main', 'map', 'mark', 'menu', 'menuitem',
  'meta', 'meter', 'nav', 'noframes', 'efines ', 'noscript', 'object',
  'ol', 'optgroup', 'option', 'output', 'p', 'param', 'pre', 'progress',
  'q', 'rp', 'rt', 'ruby', 's', 'samp', 'section', 'select',
  'small', 'source', 'span', 'strike', 'efines ', 'strong', 'style',
  'sub', 'summary', 'sup', 'table', 'tbody', 'td', 'textarea', 'tfoot',
  'th', 'thead', 'time', 'title', 'tr', 'track', 'tt', 'efines', 'u',
  'ul', 'var', 'video', 'wbr', 'h1','h2','h3','h4','h5’
```

List taken from http://www.tutorialspoint.com/html5/html5_tags.htm

If you are missing any tag you can always use the tag function

``` coffeescript
raw = html(->
  @body(->
    @tag('my-own-tag')))
```

# Versioning
## 0.0.8
 * Updated documentation
 * Corrected bug where empty tags wasn’t allowed
 * @register now handles objects and arrays aswell as a name and a function

## 0.0.7
Added @register

## 0.0.6
 * Commented the source
 * Moved elements list into main file for easier portability to client side (browser)
 * Added features to script-tag. Now you can combine attributes with content.
 * Removed default outer html tag and added doctype. Now you need to define html tag manually.

## 0.0.5
Added default tags h2 to h5 in list

## 0.0.4
Corrected bug in script-tag.

## 0.0.3
Script-tag is now an exception to the general rule of tags. It can be used either as a regular tag passing arguments. Or it can take a function. The function will be stringified and unwrapped. It will then be put inside the script tag.

# Todo
 * Same thing for CSS
 * Decide scope
 * Performance optimizations

