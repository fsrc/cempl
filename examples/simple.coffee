cempl = require('../index')

html = cempl('html', () ->
  @head(() ->
    @meta('charset':'utf-8', () -> )
    @meta('X-UA-Compatible':'IE=edge', () -> )
    @meta('Content-Language':'en', () -> )
    @meta('name':'viewport', 'content':'width=1020', () -> )
    @title(() -> @raw('my title'))
    @link(rel:'search', type:'application/opensearchdescription+xml', href:'/opensearch.xml', title:'GitHub', () -> )
    @link(rel:"fluid-icon", href:"https://github.com/fluidicon.png", title:"GitHub", () -> ))
  @body(class:"logged_in  env-production linux vis-public", (body) ->
    @a(href:'#start-of-content', tabindex:'1', 'class':'accessibility-aid js-skip-to-content', () ->
      @raw('Skip to content'))))
  .eval()

console.log(html)
