global <<< require \prelude-ls
require! net
require! events.EventEmitter
require! './common.js'
require! express
require! open

app = express()
server = require('http').createServer(app)
io = require('socket.io').listen(server)
io.set 'log level', 1

server.listen(0)
visualizationAddress = "http://localhost:#{server.address().port}/"
console.log "Visualization available at #{visualizationAddress}"
open(visualizationAddress)

app.use(express.static(__dirname + '/../public'))
app.use(express.static(__dirname + '/../out'))

client = new net.Socket

client.connect 5000, 'localhost', ->
       console.log 'connected'
       client.setEncoding 'utf8'

visualisators = []
io.sockets.on 'connection', (socket) ->
       console.log 'has visualization, joining the game'
       visualisators ++= socket
       {msgType: 'join'} |> common.toMessage |> client.write

client.on 'close' ->
  console.log 'closed'
  visualisators |> each (.close)
  process.exit()

handlePartial = common.handlePartial(client)

client.once 'data', handlePartial ''

ai = new EventEmitter

client.on 'message', (data) ->
  m = JSON.parse data
  ai.emit m.msgType, m.data

beef = (state) ->
  console.log 'got gamestate', state
  visualisators |> each (.emit 'gamestate', state)

ai.on 'gamestate', beef
ai.on 'start', (startInfo) -> console.log 'starting with:', startInfo
ai.on 'endMesg', (endData) -> console.log 'ending with:', endData
ai.on 'initialize', (initializeData) -> console.log 'initializing with:', initializeData
