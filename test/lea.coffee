{test, prepare, Promise, getTestID} = require "snapy"
try
  Lea = require "leajs-server/src/lea"
catch
  Lea = require "leajs-server"
http = require "http"

require "../src/plugin"

port = => 8081 + getTestID()

request = (path = "/", cb) =>
  filter: "headers,statusCode,-headers.date,-headers.last-modified,body"
  stream: "":"body"
  transform: body: (str) => str.length
  plain: true
  promise: new Promise (resolve, reject) =>
    http.get Object.assign({
      hostname: "localhost"
      port: port()
      agent: false

      }, {path: path}), (res) =>
        if cb?
          cb res, resolve
        else
          resolve(res)
    .on "error", reject

prepare (state, cleanUp) =>
  lea = await Lea
    config: Object.assign (state or {}), {
      listen:
        port:port()
    }
  cleanUp => lea.close()
  return lea

test {webpack: {hot: false, silent: true}}, (snap) =>
  # without hot reloading - small body
  snap request("/w/index.js")

test {webpack: {hot: true, silent: true}}, (snap) =>
  # with hot relaoding - big body
  snap request("/w/index.js")

test {webpack: {hot: true, silent: true}}, (snap, lea) =>
  # get hot relaoding info
  snap 
    filter: "headers,statusCode,-headers.date,-headers.last-modified,body"
    stream: "":"body"
    encoding: "utf8"
    transform: body: (str) =>
      if str
        str = str.toString("utf8").split("\n")
        val = JSON.parse(str[1].replace("data: ",""))
        delete val.time
        delete val.hash
        val.modules = Object.keys(val.modules).length
        return val
    plain: true
    promise: new Promise (resolve, reject) =>
      http.get Object.assign({
        hostname: "localhost"
        port: port()
        agent: false
        }, {path: "/__webpack_hmr"}), (res) =>
          setTimeout (=>
            lea.close()
            resolve(res)
          ),500
      .on "error", reject
