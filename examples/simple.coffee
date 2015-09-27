html = require('../index')

standardHeader = (title) ->
  @head(->
    @meta('charset':'utf-8', -> )
    @meta('X-UA-Compatible':'IE=edge', -> )
    @meta('Content-Language':'en', -> )
    @title(title))

raw = html(->
  @apply(standardHeader, 'My Title')
  @body(->
    @div(->
      @text("Hello")))).eval()

console.log(raw)
