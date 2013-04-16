global <<< require \prelude-ls
require! \net
require! './common.js'

players = []

broadcast = (message, sender) ->
  clients |> reject (== sender) |> each (.write common.toMessage(message))

server = net.createServer (socket) ->
  socket.setEncoding 'utf8'
  handlePartial = common.handlePartial socket

  socket.once 'data', handlePartial ''

  send = (msg) -> msg |> common.toMessage |> socket.write

  socket.once 'message', (data) ->
    msg = JSON.parse(data)
    if msg.msgType !== \join then return socket.once 'message'
    name = msg.data || "#{socket.remoteAddress}:#{socket.remotePort}"
    players ++= name
    send {msgType: 'join', data: 'Welcome!'} 
    setTimeout (-> 
      send {msgType: 'initialize', data: players}
      setTimeout (-> 
        send {msgType: 'start', data: 'starting'}
        i = 0
        intervalId = setInterval (-> send {msgType: 'gamestate', data: i++}), 100
        setTimeout (-> 
          clearInterval intervalId
          send {msgType: 'end', data: 'end'}
          players := players |> reject (== name)
          socket.end()
        ), 10000
      ), 100
    ), 100
  
server.listen 5000, -> console.log 'Now running on port 5000'
