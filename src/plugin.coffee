module.exports = ({init,position,config:confWebpack,readConf}) =>

  if confWebpack.static

    init.hookIn position.before, ({config}) =>
      {mount, output, config:configFile, folder} = config.webpack

      if not mount? or not output?
        readConf = require "read-conf"
        {
          config:{
            output:{
              publicPath, 
              path
            }
          }
        } = await readConf
          name: configFile
          folders: folder
        mount ?= publicPath
        output ?= paths

      config.folders._webpack =
        folders: [output]
        mount: mount
  else
    isCompiled = whenCompiled = null
    resetCompilation = =>
      whenCompiled = new Promise (resolve) => isCompiled = resolve
    resetCompilation()
    isRead = whenRead = null
    resetRead = =>
      whenRead = new Promise (resolve) => isRead = resolve
    resetRead()
    if confWebpack.hot != false
      lastBundles = []
      hmr = "/__webpack_hmr"
      init.hookIn position.before, ({config}) =>
        config.eventsource[hmr] = onConnect: (res) =>
          whenCompiled.then =>
            for bundle in lastBundles
              res.write bundle.replace('"action":"built"', '"action":"sync"')
              res.write "\n\n"
      write = null
      init.hookIn position.after, ({config, close}) =>
        {write, _connections} = config.eventsource[hmr]
        heartbeat = setInterval (=>
          write?("data: \uD83D\uDC93")
        ), 10000
        heartbeat.unref()
        close.hookIn => 
          clearInterval(heartbeat)
          for con in _connections
            con.end()

    init.hookIn position.after+1, ({
      config:{
        webpack:confWebpack
        },
      respond,
      position,
      Promise,
      path:{resolve}
      util: {isString, isArray}
      close
    }) =>
      webpack = require "webpack"
      MemoryFS = require "memory-fs"
      mime = require "mime"
      readConf = require "read-conf"

      mimeLookUp = {}
      mfs = new MemoryFS()

      {mount, output, silent, config:configFile, folder, hot} = confWebpack

      clientName = resolve(__dirname,"_hot-client.js")
      Plugin = require("./webpack-plugin")
      
      effMount = effOutput = null
      respond.hookIn position.before, (req) =>
        whenRead.then =>
          if ~((url = req.url).indexOf(effMount))
            whenCompiled.then =>
              filename = effOutput+url.replace(effMount,"")
              try
                req.body = mfs.readFileSync filename
              catch e
                return
              type = mimeLookUp[filename] ?= mime.getType(filename)
              if type
                req.head.contentType = type

      close.hookIn => closer?()

      {close: closer} = await readConf 
        name: configFile or "webpack.config"
        watch: true
        folders: folder or ["./build","./"]
        prop: "webpackConf"
        cancel: ({watcher}) =>
          resetRead()
          new Promise (resolve) => watcher.close(resolve) if watcher?
        cb: (base) =>
          {webpackConf} = base
          effMount = mount or webpackConf.output?.publicPath or ""
          effOutput = output or webpackConf.output?.path or "/app_build"
          isRead()
          webpackConf.mode = "development"

          if hot != false
            plgs = webpackConf.plugins ?= []
            plgs.push new Plugin(clientName, hot)
            plgs.push new webpack.HotModuleReplacementPlugin()
            plgs.push new webpack.NamedModulesPlugin()

            entry = webpackConf.entry ?= {}
            if isString(entry)
              webpackConf.entry = [clientName, entry]
            else if isArray(entry)
              entry.unshift(clientName)
            else
              for key,val of entry
                if isArray(val)
                  val.unshift(clientName) 
                else
                  entry[key] = [clientName,val]

          compiler = webpack webpackConf
          compiler.outputFileSystem = mfs

          lastHash = null
          compiler.hooks.watchRun.tap "leajs-webpack-plugin", resetCompilation

          base.watcher = compiler.watch webpackConf.watchOptions, (err, stats) =>
            
            if err?
              console.log err.stack or err
              console.log err.details if err.details
            else if lastHash != (lastHash = stats.hash)
              info = stats.toJson()
              if stats.hasErrors()
                console.log(info.errors)
              else 
                if stats.hasWarnings()
                  console.log(info.warnings)
                unless silent == true
                  console.log stats.toString(chunks: false, colors: true)
          
                if hot != false
                  stats = stats.toJson errorDetails: false
                  if stats.children? and stats.children.length > 0
                    bundles = stats.children
                  else
                    bundles = [stats]
                  lastBundles = bundles.map (stats) =>
                    "data: " + JSON.stringify({
                      action: "built"
                      name: stats.name
                      time: stats.time
                      hash: stats.hash
                      warnings: stats.warnings || []
                      errors: stats.errors || []
                      modules: stats.modules.reduce ((acc,curr) =>
                        acc[curr.id] = curr.name
                        return acc
                      ), {}
                    })

                  for bundle in lastBundles
                    write bundle
                
            isCompiled?()
            isCompiled = null
          return null

module.exports.configSchema = require("./configSchema")