var zmq = require('zeromq')
  , sock = zmq.socket('sub');

//sock.connect('tcp://127.0.0.1:3000');
console.log('Worker connected to port 3000');


sock.connect('tcp://localhost:3000')
sock.subscribe('')
sock.on('message', function(reply) {
  console.log('Received message: ', reply.toString());
})
