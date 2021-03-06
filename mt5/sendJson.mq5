#include <hiiboy/bitcoin.mqh>
#include <hiiboy/JAson.mqh>
input double  BtcScale=100;//比特币仓位系数
input string IsBtc= "BTCUSD"; //比特币品种名称
input double scale=1;//其他品种仓位系数
input string url = "http://hiiboy.com:8888/mt5";//服务器地址
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
   CJAVal json_btc;
   json_btc["symbol"] = "XBTUSD";
   json_btc["ordType"] = "Market";

   CJAVal jv;
   
   string post;
   long    ticket; 
   long hticket; 
   double   lots; 
   string   symbol;
   int   entry; 
   int   type; 
   int  magic;
   double     sl; 
   double     tp; 
   long     positionID; 
   if(result.order >0)
   {
      hticket = result.deal;
      ticket = result.order;
      if(HistoryDealSelect(hticket))
      {
         symbol = HistoryDealGetString(hticket,DEAL_SYMBOL);
         lots =HistoryDealGetDouble(hticket,DEAL_VOLUME);
         entry = HistoryDealGetInteger(hticket,DEAL_ENTRY);
         type = HistoryDealGetInteger(hticket,DEAL_TYPE); 
         //Print(HistoryDealGetInteger(hticket,DEAL_ORDER)); 
      }
      if(symbol == IsBtc)
      {
         int volume = lots*BtcScale;
         if(type == 0) json_btc["orderQty"] = volume;
         if(type == 1) json_btc["orderQty"] = -volume;
         BitCoin Btc;
         Btc.SendTicket(&json_btc);
      }
      if(HistoryOrderSelect(ticket))
      {
         //symbol=  HistoryOrderGetString(ticket,ORDER_SYMBOL); ORDER_MAGIC
         //entry=   HistoryOrderGetInteger(ticket,ORDER_TIME_SETUP); 
         //type=    HistoryOrderGetInteger(ticket,ORDER_TIME_DONE); 
         //lots=    HistoryOrderGetDouble(ticket,ORDER_VOLUME_INITIAL);//ORDER_VOLUME_CURRENT
         sl=      HistoryOrderGetDouble(ticket,ORDER_SL); 
         tp=      HistoryOrderGetDouble(ticket,ORDER_TP);
         magic =      HistoryOrderGetInteger(ticket,ORDER_MAGIC); 
         positionID =      HistoryOrderGetInteger(ticket,ORDER_POSITION_ID); 
         //Print(symbol," , ",entry," , ",type," , ",lots," , ",sl," , ",tp);  
      };

      //jv["ticket"] = ticket;
      jv["symbol"] = symbol;
      jv["entry"] = entry;
      jv["type"] = type;
      jv["lots"] = DoubleToString(formatlots(symbol,lots*scale),2);
      jv["sl"] = DoubleToString(sl,SymbolInfoInteger(symbol,SYMBOL_DIGITS));
      jv["tp"] = DoubleToString(tp,SymbolInfoInteger(symbol,SYMBOL_DIGITS));
      //jv["magic"] = magic;
      //jv["positionID"] = positionID;
      //jv["accoundID"] = AccountInfoInteger(ACCOUNT_LOGIN);
      
      if(entry == DEAL_ENTRY_IN || entry == DEAL_ENTRY_OUT) send(jv.Serialize());

   } 
   
  }


string send(string data)
{
   Print(data);
   string cookie=NULL,headers,res_headers; 
   char   post[],result[]; 
   ResetLastError(); 
   headers += "content-type:application/json\r\n";
   ArrayResize(post, StringToCharArray(data, post, 0, WHOLE_ARRAY)-1);
   //StringToCharArray(data,post);
   string str;
   int res=WebRequest("POST",url,headers,500,post,result,res_headers); 
   if(res==-1) 
     { 
      Print("Error in WebRequest. Error code  =",GetLastError()); 
      MessageBox("Add the address '"+url+"' to the list of allowed URLs on tab 'Expert Advisors'","Error",MB_ICONINFORMATION); 
     } 
   else 
     { 
      if(res==200) 
        { 
            str = CharArrayToString(result,0,WHOLE_ARRAY,CP_ACP);
            //Print(str);
        } 
      else 
         PrintFormat("Downloading '%s' failed, error code %d",url,res); 
     } 
     return str;
}

double formatlots(string symbol,double lots)
   {
     double a=0;
     double minilots=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);
     double steplots=SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP);
     if(lots<minilots) return(0);
     else
      {
        double a1=MathFloor(lots/minilots)*minilots;
        a=a1+MathFloor((lots-a1)/steplots)*steplots;
      }
     return(a);
   }