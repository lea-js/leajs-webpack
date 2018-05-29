VirtualModulePlugin = require('virtual-module-webpack-plugin')


module.exports = class Config
  constructor: (name, options) ->
    queryStr = ""
    options = {} if options == true
    options.reload ?= true
    
    tmp = []
    for k,v of options
      tmp.push k+"="+v
    queryStr = "?"+tmp.join("&")
    
    return new VirtualModulePlugin
      path: name 
      contents: """
        require('eventsource-polyfill')
        require('webpack-hot-middleware/client#{queryStr}')
      """
    