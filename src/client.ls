global <<< require \prelude-ls
require! \net
require! './common.js'

client = new net.Socket

client.connect 5000, 'localhost', ->
       console.log 'connected'
       client.setEncoding 'utf8'
       {author: 'kuikelo', text: 'hello'} |> common.toMessage |> client.write


client.on 'close' -> 
  console.log 'closed'
  process.exit()

handlePartial = common.handlePartial(client)

client.once 'data', handlePartial ''

client.on 'message' (data) ->
          m = JSON.parse data
          if m.meta then console.log "* #{m.meta} *"
          if m.author and m.text then console.log "#{m.author}: #{m.text}"
