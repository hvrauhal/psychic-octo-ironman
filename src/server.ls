global <<< require \prelude-ls
require! \net
require! './common.js'

clients = []

broadcast = (message, sender) ->
  clients |> reject (== sender) |> each (.write common.toMessage(message))

server = net.createServer (socket) ->
  socket.setEncoding 'utf8'
  handlePartial = common.handlePartial socket

  socket.name = "#{socket.remoteAddress}:#{socket.remotePort}"
  clients ++= socket

  {meta: "Welcome #{socket.name}"} |> common.toMessage |> socket.write
  
  broadcast {meta: socket.name + " joined the chat"}, socket

  socket.once 'data', handlePartial ''

  socket.on 'message', (data) ->
    line = JSON.parse(data)
    broadcast(line, socket)

  removeClient = ->
    clients := reject (== socket), clients
    broadcast {meta: socket.name + " left the chat."}
  
  socket.on 'close', removeClient

server.listen 5000, -> console.log 'Now running on port 5000'
