global <<< require \prelude-ls
net = require('net')

client = net.createConnection 5000, localhost, -> console.log('connected')
client.on 'close' 
