{resolve} = require "path"
module.exports =
  entry:
    index: "./app/entry.js"
  output:
    publicPath: "w/"
    filename: "[name].js"
    path: resolve("./app")
  