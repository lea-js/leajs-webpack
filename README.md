# leajs-webpack

Plugin of [leajs](https://github.com/lea-js/leajs-server).

Webpack development and hot reload middleware.

## leajs.config

```js
module.exports = {

  plugins: [
    "leajs-webpack"
  ]

  // Configuration object
  // type: Object
  webpack: {

    // Name of the webpack configuration file
    config: "webpack.config", // String

    // Folders to search for webpack configuration file
    folder: ["./build","./"], // [Array, String]

    // Options to pass to hot middleware client. Set False to deactivate hot module reloading.
    hot: {}, // [Object, Boolean]

    // Namespace to use in Url e.g. /webpack
    // Default: Read from webpack.config 'output.publicPath'
    mount: null, // String

    // Output folder of webpack
    // Default: Read from webpack.config 'output.path'
    output: null, // String

    // No compiling, only serve the compiled bundle as a folder
    // Default: inProduction
    static: null, // Boolean

  // …

}
```

## License
Copyright (c) 2018 Paul Pflugradt
Licensed under the MIT license.