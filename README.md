# nodejs  
# npm install zeromq  
# push/pull 模式 服务端push，客户端pull，只有一个客户端才能接收到数据  
# pub/sub 模式，客户端各方都能接收到数据
# mt5:sendjson.mq5; mt4:接收端zeromq.mq4; nodejs：pub2mt4.js

#Push/Pull  

// producer.js  
var zmq = require('zeromq')  
  , sock = zmq.socket('push');  

sock.bindSync('tcp://127.0.0.1:3000');  
console.log('Producer bound to port 3000');  

setInterval(function(){  
  console.log('sending work');  
  sock.send('some work');  
}, 500);  

// worker.js
var zmq = require('zeromq')
  , sock = zmq.socket('pull');

sock.connect('tcp://127.0.0.1:3000');
console.log('Worker connected to port 3000');

sock.on('message', function(msg){
  console.log('work: %s', msg.toString());
});
#---------------------------------------------------   
// pubber.js
var zmq = require('zeromq')
  , sock = zmq.socket('pub');

sock.bindSync('tcp://127.0.0.1:3000');
console.log('Publisher bound to port 3000');

setInterval(function(){
  console.log('sending a multipart message envelope');
  sock.send(['kitty cats', 'meow!']);
}, 500);

// subber.js
var zmq = require('zeromq')
  , sock = zmq.socket('sub');

sock.connect('tcp://127.0.0.1:3000');
sock.subscribe('kitty cats');
console.log('Subscriber connected to port 3000');

sock.on('message', function(topic, message) {
  console.log('received a message related to:', topic, 'containing message:', message);
});
