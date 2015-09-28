_ = require('lodash')

elements = require('./elements')

unwrapFunctionToString = (fn) ->
  code = fn.toString()
  lines = code.split('\n')
  lines = _.initial(_.tail(lines))
  lines = _.map(lines, (line) -> _.trim(line))
  lines.join("")

ensureArguments = (tag, attr, content) ->
  f    = null
  text = null

  if not _.isString(tag)
    throw "Tag must be a string"

  if _.isPlainObject(attr)
    attr = attr
  else if (_.isString(attr) or _.isFunction(attr)) and _.isUndefined(content)
    content = attr
    attr = null

  if _.isFunction(content)
    f = content
  else if _.isString(content)
    text = content

  [tag, attr, f, text]

markup = (intag, inattr, incontent) ->
  [tag, attr, f, text] = ensureArguments(intag, inattr, incontent)

  do (tag, attr, f) ->
    children = []

    tagfn = (t, a, f) ->
      children.push(markup(t, a, f))
      wrapper

    all = _.reduce(elements, (obj, name) ->
        obj[name] = _.bind(tagfn, null, name)
        obj
      , {})

    wrapper =
      apply : (f, args...) -> _.bind(f, wrapper, args...)()

      tag : tagfn

      text : (text) -> children.push(eval:() -> text)

      script : (ref) ->
        if _.isPlainObject(ref)
          children.push(eval:() ->
            attribs = ""
            attribs = " " + _.map(attr, (v, k) ->
              "#{k}='#{v}'"
            ).join(' ')

            """<script#{attribs}></script>""")

        else if _.isFunction(ref)
          children.push(eval:() ->
            """<script>#{unwrapFunctionToString(ref)}</script>""")

      eval : () ->
        if text?
          inner = text
        else
          inner = _.map(children, (child) -> child.eval()).join("")

        attribs = ""
        attribs = " " + _.map(attr, (v, k) ->
          "#{k}='#{v}'"
        ).join(' ') if attr?

        if tag?
          """<#{tag}#{attribs}>#{inner}</#{tag}>"""
        else
          inner

    wrapper = _.assign(wrapper, all)

    _.bind(f, wrapper)() if f?
    wrapper

module.exports = (f) ->
  markup('html', f)

