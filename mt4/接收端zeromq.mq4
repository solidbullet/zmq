
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include<JAson.mqh>
#include <Zmq/Zmq.mqh>
int magic = 888;
void OnStart()
  {
   
  // CJAVal jv;
   CJAVal json;
   //jv["ticket"] = 9861503;
   //jv["symbol"] = "XAUUSD";
   //jv["entry"] = 0;
   //jv["type"] = 0;
   //jv["lots"] = 0.01;
   //jv["sl"] = 0;
   //jv["tp"] = 0;
   //jv["magic"] = 0;
   //jv["positionID"] = 9861503;
   //jv["accoundID"] = AccountInfoInteger(ACCOUNT_LOGIN);
   //string jsonstr = jv.Serialize();
   //json.Deserialize(jsonstr);
   

   
   
   Context context;

//  Socket to talk to server
   Print("Collecting updates from weather server…");
   Socket subscriber(context,ZMQ_SUB);
   subscriber.connect("tcp://127.0.0.1:3000");
   
   while(!IsStopped())
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
      int magic = json["magic"].ToInt();
      double lots = json["lots"].ToDbl();
      double sl = json["sl"].ToDbl();
      double tp = json["tp"].ToDbl();
      Print(symbol,"  ",entry,"  ",type,"  ",lots,"  ",sl,"  ",tp);
      buy(symbol,lots,sl,tp,"follow_buy",magic);
      Sleep(60*60);
   }
   
   
   //Print(symbol,"  ",entry,"  ",type,"  ",lots,"  ",sl,"  ",tp);
   
  }
//+------------------------------------------------------------------+
int buy(string symbol,double lots,double sl,double tp,string com,int buymagic)
  {
    double vask    = MarketInfo(symbol,MODE_ASK); 
    int a=0;
    bool zhaodan=false;
     for(int i=0;i<OrdersTotal();i++)
      {
        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
          {
            string zhushi=OrderComment();
            int ma=OrderMagicNumber();
            if(OrderSymbol()==symbol && OrderType()==OP_BUY && zhushi==com && ma==buymagic)
              {
                zhaodan=true;
                break;
              }
          }
      }
    if(zhaodan==false)
      {
        if(sl!=0 && tp==0)
         {
          a=OrderSend(symbol,OP_BUY,lots,vask,50,vask-sl*Point,0,com,buymagic,0,White);
         }
        if(sl==0 && tp!=0)
         {
          a=OrderSend(symbol,OP_BUY,lots,vask,50,0,vask+tp*Point,com,buymagic,0,White);
         }
        if(sl==0 && tp==0)
         {
          a=OrderSend(symbol,OP_BUY,lots,vask,50,0,0,com,buymagic,0,White);
         }
        if(sl!=0 && tp!=0)
         {
          a=OrderSend(symbol,OP_BUY,lots,vask,50,vask-sl*Point,vask+tp*Point,com,buymagic,0,White);
         } 
      }
    return(a);
  }
int sell(string symbol,double lots,double sl,double tp,string com,int sellmagic)
  {
    double vbid    = MarketInfo(symbol,MODE_BID);
    int a=0;
    bool zhaodan=false;
     for(int i=0;i<OrdersTotal();i++)
      {
        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
          {
            string zhushi=OrderComment();
            int ma=OrderMagicNumber();
            if(OrderSymbol()==symbol && OrderType()==OP_SELL && zhushi==com && ma==sellmagic)
              {
                zhaodan=true;
                break;
              }
          }
      }
    if(zhaodan==false)
      {
        if(sl==0 && tp!=0)
         {
           a=OrderSend(symbol,OP_SELL,lots,vbid,50,0,vbid-tp*Point,com,sellmagic,0,Red);
         }
        if(sl!=0 && tp==0)
         {
           a=OrderSend(symbol,OP_SELL,lots,vbid,50,vbid+sl*Point,0,com,sellmagic,0,Red);
         }
        if(sl==0 && tp==0)
         {
           a=OrderSend(symbol,OP_SELL,lots,vbid,50,0,0,com,sellmagic,0,Red);
         }
        if(sl!=0 && tp!=0)
         {
           a=OrderSend(symbol,OP_SELL,lots,vbid,50,vbid+sl*Point,vbid-tp*Point,com,sellmagic,0,Red);
         }
      }
    return(a);
  }