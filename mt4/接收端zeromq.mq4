#property copyright "WeChat:13818571403"
#property link      "https://www.hiiboy.com"
#property version   "1.00"
#property strict
#property script_show_inputs
#include<Zmq/JAson.mqh>
#include <Zmq/Zmq.mqh>
input double scale = 1;
int magic = 10101;
void OnStart()
  {

   CJAVal json;
   Context context;

   Print("Collecting updates from weather server…");
   Socket subscriber(context,ZMQ_SUB);
   subscriber.connect("tcp://hiiboy.com:3000");
   
   while(true)
   {
      subscriber.subscribe("{");
      ZmqMsg update;
      subscriber.recv(update);
   
      string msg=update.getData();
      Print(msg);
      json.Deserialize(msg);
      string symbol = json["symbol"].ToStr();
      int entry = json["entry"].ToInt();
      int type = json["type"].ToInt();
      //int magic = json["magic"].ToInt();
      double lots = formatlots(symbol,json["lots"].ToDbl()*scale);
      double sl = json["sl"].ToDbl();
      double tp = json["tp"].ToDbl();
      Print(symbol,"  ",entry,"  ",type,"  ",lots,"  ",sl,"  ",tp);
      if(entry == 0)
      {
         double vask    = MarketInfo(symbol,MODE_ASK); 
         double vbid    = MarketInfo(symbol,MODE_BID);
         if(type == 0) OrderSend(symbol,OP_BUY,lots,vask,100,sl,tp,"JYQ_EA_BUY",magic,0,clrAliceBlue);
         if(type == 1) OrderSend(symbol,OP_SELL,lots,vbid,100,sl,tp,"JYQ_EA_SELL",magic,0,clrAntiqueWhite);
      }
      if(entry == 1) close_ticket(type,lots,symbol);

      
      Sleep(60*60);
   }
      
  }

void close_ticket(int type,double lots,string symbol)
{
   for(int i=OrdersTotal()-1;i>=0;i--)
   {
     if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
       {
         int pre_magic = GlobalVariableGet(IntegerToString(OrderTicket()));
         if(OrderSymbol() != symbol) continue;
         if(OrderMagicNumber() != magic && pre_magic != magic) continue;
         if(type == 0 && OrderType() == OP_SELL)
         {
            if(OrderLots() == lots) OrderClose(OrderTicket(),lots,OrderClosePrice(),100,clrAliceBlue);
            if(lots < OrderLots() && MathAbs(lots - OrderLots()) > 0.01)
            {
               bool res = OrderClose(OrderTicket(),lots,OrderClosePrice(),100,clrAliceBlue);
               if(res)
               {
                  if(OrderSelect(OrdersTotal()-1,SELECT_BY_POS,MODE_TRADES))
                  {
                  GlobalVariableSet(OrderTicket(),magic);
                  return;
                  }   
               }
            }
            if(MathAbs(lots - OrderLots()) == 0.01)  OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),100,clrAliceBlue);        
         }
         if(type == 1 && OrderType() == OP_BUY)
         {
            if(OrderLots() == lots) OrderClose(OrderTicket(),lots,OrderClosePrice(),100,clrAliceBlue);
            if(lots < OrderLots() && MathAbs(lots - OrderLots()) > 0.01)
            {
               bool res = OrderClose(OrderTicket(),lots,OrderClosePrice(),100,clrAliceBlue);
               if(res)
               {
                  if(OrderSelect(OrdersTotal()-1,SELECT_BY_POS,MODE_TRADES))
                  {
                  GlobalVariableSet(OrderTicket(),magic);
                  return;
                  }   
               }
            }
            if(MathAbs(lots - OrderLots()) == 0.01)  OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),100,clrAliceBlue);
         }
       }
   }
}

double formatlots(string symbol,double lots)
{
     double a=0;
     double minilots=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);
     double steplots=SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP);
     if(minilots == 0)
     {
      Alert("此平台没有"+symbol+"品种");
      return(0);
     }
     if(lots<minilots) return(0);
     else
      {
        double a1=MathFloor(lots/minilots)*minilots;
        a=a1+MathFloor((lots-a1)/steplots)*steplots;
      }
     return(a);
}