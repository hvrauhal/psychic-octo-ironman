exports.toMessage = (obj) -> JSON.stringify(obj) + '\n'

handlePartial = exports.handlePartial = (socket, oldData, newData) --> 
      msg = oldData + newData
      if 10 == msg.charCodeAt(msg.length-1)
        socket.emit 'message', msg.substring(0, msg.length-1)
        socket.once 'data', handlePartial socket, ''
      else 
        socket.once 'data', handlePartial socket, msg
