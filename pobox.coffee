fs = require 'fs'
path = require 'path'

boxes = {}

main = ->
  config = JSON.parse(fs.readFileSync("pobox.json", "utf8"))
  console.log config

  poboxDir = path.resolve("box")
  try
    fs.mkdirSync(poboxDir)
  catch
    # meh
  if not fs.existsSync(poboxDir)
    console.log "ERROR: Can't create: #{poboxDir}"
    return

  port = 3020
  express = require('express')
  app = express()
  app.use(express.json())
  app.post '/push/:box/:secret', (req, res) ->
    if (req.params.secret != config.secret) or not req.params.box?
      res.send("naw")
      return
    if not boxes[req.params.box]?
      boxes[req.params.box] = []
    boxes[req.params.box].push req.body
    res.type('application/json')
    res.send(JSON.stringify("OK"))
  app.get '/pull/:box/:secret', (req, res) ->
    if (req.params.secret != config.secret) or not req.params.box?
      res.send("naw")
      return
    res.type('application/json')
    boxContents = []
    if boxes[req.params.box]?
      boxContents = boxes[req.params.box]
      boxes[req.params.box] = []
    res.send(JSON.stringify(boxContents))

  app.get '*', (req, res) ->
    res.send('naw')
  app.post '*', (req, res) ->
    res.send('naw')
  app.listen port, ->
    console.log("POBox listening on port #{port}")

main()
