#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property version   "1.00"
#property strict
#property show_inputs

input string InpZipCode=""; // ZipCode to subscribe to, default is NYC, 10001

#include <Zmq/Zmq.mqh>
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   Context context;

//  Socket to talk to server
   Print("Collecting updates from weather server…");
   Socket subscriber(context,ZMQ_SUB);
   subscriber.connect("tcp://127.0.0.1:3000");
   
   while(!IsStopped())
   {
      subscriber.subscribe("sAAPL");
      ZmqMsg update;
      subscriber.recv(update);
   
      string msg=update.getData();
      Print("msg: ",msg);
      Sleep(60*60);
   }
  }