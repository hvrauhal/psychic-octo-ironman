global <<< require \prelude-ls
require! \net
require! './common.js'

client = new net.Socket

client.connect 5000, 'localhost', ->
       console.log 'connected'
       client.setEncoding 'utf8'
       {msgType: 'join'} |> common.toMessage |> client.write

client.on 'close' -> 
  console.log 'closed'
  process.exit()

handlePartial = common.handlePartial(client)

client.once 'data', handlePartial ''

client.on 'message', (data) ->
  m = JSON.parse data
  type = if m.msgType === 'end' then 'endMesg' else m.msgType
  client.emit type, m.data

beef = (state) ->
  console.log 'got gamestate', state

client.on 'gamestate', beef

client.on 'start', (startInfo) -> console.log 'starting with:', startInfo
client.on 'endMesg', (endData) -> console.log 'ending with:', endData
client.on 'initialize', (initializeData) -> console.log 'initializing with:', initializeData
