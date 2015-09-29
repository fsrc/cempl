_ = require('lodash')

## Predefined elements/tags
elements = [
  'a', 'abbr', 'acronym', 'efines ', 'address', 'applet',
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
  'ul', 'var', 'video', 'wbr', 'h1','h2','h3','h4','h5']

### unwrapFunctionToString()
# purpose: convert function into string that can
#          be sent over to client side
#
# in:      function
# out:     string with code within the function
###
unwrapFunctionToString = (fn) ->
  _(fn.toString()) # convert function to string
    .split('\n')   # split string in lines
    .initial()     # remove last line
    .tail()        # remove first line
    .map(_.trim)   # trim whitespace from lines
    .join("")      # join code back into a string
    # Coffee-Script generates a return statement which
    # is not wanted. If code was originaly Coffee-Script
    # we remove that return statement
    .replace(/^return\s/, "")

### ensureMarkupArguments()
# purpose: helper function to the markup() function that
#          ensures that the arguments sent in to markup()
#          is correct
# in:      tag     - name of tag
#          attr    - attribute object
#          content - either a function or a string
# out:     [tag, attr, f, text] - array of the correct arguments
###
ensureMarkupArguments = (tag, attr, content) ->
  # one of these is the reesult of content
  f    = null
  text = null

  # make sure that the first argument is a string
  # the string will be used as tag name
  if not _.isString(tag)
    throw "Tag must be a string"

  # if attr is a plain object, then it is defined
  # in the right place
  if _.isPlainObject(attr)
    # just a dummy operation
    attr = attr
  # if it's not a plain object, it is allowed to be
  # either a string or a function, but in that case, content
  # must be null/undefined
  else if (_.isString(attr) or _.isFunction(attr)) and _.isUndefined(content)
    content = attr # pass on the value of attr to content
    attr = null    # make sure we dont use attr
  else if _.isUndefined(attr)
    attr = null
  else
    throw "In '#{tag}' attributes must be plain objects and content must be string or function"

  # if content is a function
  if _.isFunction(content)
    f = content # store content in the f var

  # if content is a string
  else if _.isString(content)
    text = content # stor content in the text var

  # return the collective result
  [tag, attr, f, text]

### markup()
# purpose: represents a node in the html tree
# in:      intag - the name of the tag to represent
#          inattr - the attributes to go with the tag (plain object)
#          incontent - the content to be wrapped by the tag
# out:     the wrapper object, which contains functions that
#          can be executed upon the tag
###
markup = (registeredFunctions, intag, inattr, incontent) ->
  # make sure that the arguments is correct and set them up
  [tag, attr, f, text] = ensureMarkupArguments(intag, inattr, incontent)

  # create a closure so that async stuff won't fail
  do (tag, attr, f, text) ->
    # keeps track of any child tags
    children = []

    ### tagfn()
    # purpose: it's called whenever a tag is executed, for instance
    #          @body or @tag('mytag'). the arguments is passed on
    #          to the markup() function, and the result of the
    #          markup() function is pushed on to the children array
    # in:      args... - any arguments that the markup() function
    #          would allow
    # out:     the current wrapper
    ###
    tagfn = (args...) ->
      children.push(markup(registeredFunctions, args...))
      wrapper

    # this variable represents all default tags that is defined
    # in the elements list. basically the all array contains a
    # list of curried tagfn calls, where the first argument (tag)
    # applied. the functions is later added to the wrapper object
    all = _.reduce(elements, (obj, name) ->
        obj[name] = _.bind(tagfn, null, name)
        obj
      , {})

    wrapper =
      ### apply()
      # purpose: enables the generator to be extended with
      #          predefined functions. the result will be mixed in
      #          on the same level as other siblings
      # in:      f - function that should be mixed in
      #          args... - any arguments that the function takes
      # out:     unknown
      ###
      apply : (f, args...) -> _.bind(f, wrapper, args...)()

      register : (name, f) ->
        if _.isObject(name)
          _.assign(registeredFunctions, name)
        else if _.isArray(name)
          _.reduce(name, (registered, newfn) ->
            _.assign(registered, newfn)
            registered
          , registeredFunctions)
        else if _.isString(name) and _.isFunction(f)
          registeredFunctions[name] = f
          wrapper[name] = _.bind(f, wrapper)
        else
          throw "@register either takes an object, array or a string and a function"

      ### tag()
      # purpose: enables the programmer to use an arbitrary tag
      #          by passing the first parameter tag as the name
      #          of the tag. for more info look at tagfn()
      ###
      tag : tagfn

      ### text()
      # purpose: allows user to insert any string within the tag
      # in:      text - the string to be inserted
      # out:     unknown
      ###
      text : (text) -> children.push(eval:() -> text)

      ### doctype()
      # purpose: be able to set doc type
      # in:      attr - the string to accompany the doctype tag
      #          for simplicity, this defaults to "html" as of
      #          html5 standard
      # out:     unknown
      ###
      doctype : (attr) ->
        children.push(
          eval:() ->
            attr = "html" if _.isUndefined(attr)
            "<!DOCTYPE #{attr}>")


      ### script()
      # purpose: allows the user to define a script tag. this is
      #          an exception to the other default tags because
      #          it can take a function as an argument. the function
      #          will be stringified, unwrapped and sent to the
      #          client as a string within the script tag
      # in:      attr - any tag attributes
      #          content - function that will be stringified and unwrapped
      #          and sent to the client within the script tag or string
      #          that will be sent within the script tag
      # out:     unknown
      ###
      script : (scrattr, scrcontent) ->

        # If the passed scrattr is a object
        if _.isPlainObject(scrattr)
          scrattr = scrattr

        # If the passed scrattr is a function
        else if (_.isFunction(scrattr) or _.isString(scrattr)) and _.isUndefined(scrcontent)
          scrcontent = scrattr
          scrattr = null

        else
          throw "Script tag attributes must be plain object"

        # If scrcontent is a function, convert it to a string
        if _.isFunction(scrcontent)
          scrcontent = unwrapFunctionToString(scrcontent)
        else if _.isString(scrcontent)
          scrcontent = scrcontent
        else if _.isUndefined(scrcontent)
          scrcontent = ""
        else
          throw "Script tag scrcontent must be either a string or a function"

        # Push the tag onto the children array
        children.push(eval: () ->
          attribs = ""
          attribs = " " + _.map(scrattr, (v, k) ->
            "#{k}='#{v}'"
          ).join(' ') if scrattr
          """<script#{attribs}>#{scrcontent}</script>""")


    outer =
      ### before()
      # purpose: insert element in position before this tag
      ###
      before : (f) -> throw "Not implemented"
      ### before()
      # purpose: insert element in position after this tag
      ###
      after  : (f) -> throw "Not implemented"

      # Evaluate to string
      eval : () ->
        if text?
          inner = text
        else
          inner = _.map(children, (child) -> child.eval()).join("")

        attribs = ""
        attribs = " " + _.map(attr, (v, k) ->
          "#{k}='#{v}'"
        ).join(' ') if attr?

        if tag == "root_cempl_document"
          inner
        else if tag?
          """<#{tag}#{attribs}>#{inner}</#{tag}>"""
        else
          inner

    # Make sure that we get all default tags aswell
    wrapper = _.assign(wrapper, all, registeredFunctions)

    # Execute the content function so that we can generate
    # inner html to this tag
    _.bind(f, wrapper)() if f?

    # Returns the outer wrapper. It only contains
    #  - eval()
    #  - before()
    #  - after()
    outer

module.exports = (f) ->
  markup({}, 'root_cempl_document', f)

