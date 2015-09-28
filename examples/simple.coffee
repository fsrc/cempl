document = require('../index')

# Define a component that can be reused
standardHeader = (title) ->
  @head ->
    # HTML tag attributes is passed on as objects
    @meta 'charset':'utf-8'
    @meta 'X-UA-Compatible':'IE=edge'
    @meta 'Content-Language':'en'
    # Variables is of course possible to use
    @title title

# Wrap any construct in a component and put
# the children where they belong
wrapperFeature = (children) ->
  @div class:'container', ->
    @div class:'row', ->
      @div class:'col-md-12', children

raw = document ->
  # Note, tags with no arguments must have empty parenthesis
  # otherwise they will not be executed
  @doctype()
  @html ->
    # @apply makes it possible to build components
    @apply standardHeader, 'My Title'
    @body ->
      # it's possible to pass children on to a component
      @apply wrapperFeature, ->
        # Uses the @text function to insert inner html
        @div -> @text "Hello"
        # Passes the inner html as argument
        @div "World"
      @script type:'javascript', ->
        # This code will be converted into javascript
        # and passed on to the client
        console.log('my javascript')

# eval evaluates the tree and returns the html as string
console.log(raw.eval())
