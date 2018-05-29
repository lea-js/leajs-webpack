module.exports =
  webpack: 
    type: Object 
    default: {}
    desc: "Configuration object"
  webpack$static:
    type: Boolean
    default: process.env.NODE_ENV == "production"
    _default: "inProduction"
    desc: "No compiling, only serve the compiled bundle as a folder"
  webpack$mount:
    type: String
    _default: "Read from webpack.config 'output.publicPath'"
    desc: "Namespace to use in Url e.g. /webpack"
  webpack$output:
    type: String
    _default: "Read from webpack.config 'output.path'"
    desc: "Output folder of webpack"
  webpack$config:
    type: String
    default: "webpack.config"
    desc: "Name of the webpack configuration file"
  webpack$folder:
    types: [Array, String]
    default: ["./build","./"]
    desc: "Folders to search for webpack configuration file"
  webpack$hot:
    types: [Object,Boolean]
    default: {}
    desc: "Options to pass to hot middleware client. Set False to deactivate hot module reloading."