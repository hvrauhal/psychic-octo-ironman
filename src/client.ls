global <<< require \prelude-ls
net = require('net')

client = new net.Socket
client.connect 5000, 'localhost', ->
       console.log 'connected'
       client.setEncoding 'utf8'
       longText = (for i from 1 to 100000
                    "abcd" + i).join(' ')
       client.write(JSON.stringify({author: client.address().address + ":" + client.address().port, text: longText }) + '\n')

client.on 'close' -> 
  console.log 'closed'
  process.exit()
handlePartial = (oldData, newData) --> 
  msg = oldData + newData
  if 10 == msg.charCodeAt(msg.length-1)
    client.emit 'message', msg.substring(0, msg.length-1)
    client.once 'data', handlePartial ''
  else 
    client.once 'data', handlePartial msg

client.once 'data', handlePartial ''

client.on 'message' (data) ->
          m = JSON.parse data
          if m.meta then console.log "* #{m.meta} *"
          if m.author and m.text then console.log "#{m.author}: #{m.text}"
