global <<< require \prelude-ls
net = require('net')

clients = []

server = net.createServer (socket) ->
    broadcast = (message, sender) ->
      each ((client) -> if client !== sender then client.write(JSON.stringify(message) + "\n")), clients

    socket.name = "#{socket.remoteAddress}:#{socket.remotePort}"
    clients ++= socket
    socket.write JSON.stringify({meta: "Welcome #{socket.name}"}) + '\n'
    broadcast {meta: socket.name + " joined the chat"}, socket

    socket.setEncoding 'utf8'

    handlePartial = (oldData, newData) --> 
      msg = oldData + newData
      if 10 == msg.charCodeAt(msg.length-1)
        socket.emit 'message', msg.substring(0, msg.length-1)
        socket.once 'data', handlePartial ''
      else 
        socket.once 'data', handlePartial msg

    socket.once 'data', handlePartial ''

    socket.on 'message', (data) ->
      line = JSON.parse(data)
      broadcast(line, socket)

    removeClient = ->
      clients := reject (== socket), clients
      broadcast {meta: socket.name + " left the chat."}
    socket.on 'close', removeClient

server.listen 5000, -> console.log 'Now running on port 5000'
