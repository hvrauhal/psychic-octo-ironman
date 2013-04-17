socket = io.connect 'http://localhost'

var context


<-! $
$visu = $ '#visu'
context := $visu[0].getContext '2d'
context.fillStyle = 'red'

socket.on 'gamestate', (data) ->
  context.fillRect(data, data, 1, 1)
  

