global <<< require \prelude-ls
net = require('net')

clients = []

server = net.createServer (socket) ->
    broadcast = (message, sender) ->
        each ((client) -> if client !== sender then client.write message ), clients
        process.stdout.write(message + '\n')

    socket.name = "#{socket.remoteAddress}:#{socket.remotePort}"
    clients ++= socket
    socket.write "Welcome " + socket.name + "\n"
    broadcast socket.name + " joined the chat\n", socket

    socket.on 'data', (data) ->
        line = JSON.parse(data)
        broadcast(socket.name + " "  + line.author + "> " + line.text, socket)
// {"author" : "kuikkeloinen", "text": "Helloworld"}

    socket.on 'end', ->
        clients.splice(clients.indexOf(socket), 1)
        broadcast(socket.name + " left the chat.\n")

server.listen(5000, -> console.log 'Now running on port 5000')
