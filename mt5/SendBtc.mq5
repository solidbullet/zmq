#include <hiiboy/bitcoin.mqh>
#include <hiiboy/JAson.mqh>
input double  BtcScale=100;//比特币仓位系数
input string IsBtc= "BTCUSD";//比特币品种名称
int OnInit()
  {
   return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason)
  {

  }
void OnTick()
  {
  
  }
  
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
{
   double   lots; 
   string   hsymbol;
   int   entry; 
   int   type; 
   if(result.order >0)
   {
      
      CJAVal jv;
      jv["symbol"] = "XBTUSD";
      jv["ordType"] = "Market";
      int hticket = result.deal;
      if(HistoryDealSelect(hticket))
      {
         hsymbol = HistoryDealGetString(hticket,DEAL_SYMBOL);
         lots =HistoryDealGetDouble(hticket,DEAL_VOLUME);
         entry = HistoryDealGetInteger(hticket,DEAL_ENTRY);
         type = HistoryDealGetInteger(hticket,DEAL_TYPE); 
      }
      if(hsymbol != IsBtc) return; 
      if(type == 0) jv["orderQty"] = lots*BtcScale;
      if(type == 1) jv["orderQty"] = -lots*BtcScale;
      BitCoin Btc;
      Btc.SendTicket(&jv);
   } 
}

