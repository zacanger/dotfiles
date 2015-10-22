#!/bin/sh

browser="google-chrome"
dir="node_webchat"
mkdir $dir
cd $dir

if [ ! -f "/usr/bin/nodejs" ]
then
  sudo apt-get install nodejs
fi

npm install --save express@4.10.2
npm install --save socket.io

cat << EOF > server.js
var app = require('express')();
var http = require('http').Server(app);
var io = require('socket.io')(http);

app.get('/', function(req, res){
  res.sendFile(__dirname + '/index.html');
});

io.on('connection', function(socket){
  socket.on('chat message', function(msg){
    io.emit('chat message', msg);
    console.log(msg); //for server monitoring.
    //process.stdout.write(msg);

  });
});

http.listen(3000, function(){
  console.log('listening on *:3000');
});
EOF

cat << EOH > index.html
<!doctype html>
<html>
  <head>
    <title>Socket.IO chat</title>
    <style>
      * { margin: 0; padding: 0; box-sizing: border-box; }
      body { font: 13px Helvetica, Arial; }
      form { background: #000; padding: 3px; position: fixed; bottom: 0; width: 100%; }
      form input { border: 0; padding: 10px; width: 90%; margin-right: .5%; }
      form button { width: 9%; background: rgb(130, 224, 255); border: none; padding: 10px; }
      #messages { list-style-type: none; margin: 0; padding: 0; }
      #messages li { padding: 5px 10px; }
      #messages li:nth-child(odd) { background: #eee; }
    </style>
  </head>
  <body>
    <ul id="messages"></ul>
    <form action="">
      <input id="m" autocomplete="off" /><button>Send</button>
    </form>
    <script src="https://cdn.socket.io/socket.io-1.2.0.js"></script>
    <script src="http://code.jquery.com/jquery-1.11.1.js"></script>
    <script>
      var socket = io();
      \$('form').submit(function(){
        socket.emit('chat message', \$('#m').val());
        \$('#m').val('');
        return false;
      });
      socket.on('chat message', function(msg){
        \$('#messages').append(\$('<li>').text(msg));
      });
    </script>
  </body>
</html>
EOH

$browser "http://127.0.0.1:3000" &
$browser "http://127.0.0.1:3000" &
nodejs server.js