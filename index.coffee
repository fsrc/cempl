_ = require('lodash')

elements = require('./elements')

markup = (tag, attr, f) ->
  if _.isFunction(attr) and not f?
    f = attr
    attr = null
  else if _.isFunction(tag) and not f?
    f = tag
    tag = null
    attr = null

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
      tag : tagfn
      raw : (text) -> children.push(eval:() -> text)
      eval : () ->
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

module.exports = markup

