module.exports =
  plugins: ["./src/plugin"]
  respond: (res) =>
    if res.url == "/"
      res.body ="""
        <html><head>
        <script src="w/index.js"></script>
        </head><body>
        hello1
        </body></html>
        """