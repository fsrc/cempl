html = require('../index')

# Define a component that can be reused
standardHeader = (title) ->
  @head(->
    # HTML tag attributes is passed on as objects
    @meta('charset':'utf-8')
    @meta('X-UA-Compatible':'IE=edge')
    @meta('Content-Language':'en')
    # Variables is of course possible to use
    @title(title))

raw = html(->
  # @apply makes it possible to build components
  @apply(standardHeader, 'My Title')
  @body(->
    # Uses the @text function to insert inner html
    @div(-> @text("Hello"))
    # Passes the inner html as argument
    @div("World")
  # eval evaluates the tree and returns the html as string
  )).eval()

console.log(raw)
