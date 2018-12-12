#include <hiiboy\JAson.mqh>

class BitCoin 
  { 
	protected: 
	   string              url;                     // 名称 
	   //CJAVal              *json;
	public: 
		   //--- 缺省构造函数 
				BitCoin(){url = "http://47.105.165.39/bitmex";}; 
		   //--- 参数构造函数 
				~BitCoin(){}; 
	   void     SetUrl(string n); 
	   string   GetUrl();
	   void     SendTicket(CJAVal *json);
	private: 

  }; 
  
void BitCoin::SetUrl(string n) 
  { 
   url = n; 
  } 
  
string BitCoin::GetUrl() 
  { 
   return url; 
  } 
  
  void BitCoin::SendTicket(CJAVal *json) 
  { 
   string postbody = json.Serialize();
   string cookie=NULL,headers,res_headers; 
   headers += "content-type:application/json\r\n";
   char  result[]; 
   char data[]; 
   ArrayResize(data, StringToCharArray(json.Serialize(), data, 0, WHOLE_ARRAY)-1);
   string result_str;
   int res=WebRequest("POST",url,headers,500,data,result,res_headers); 
   if(res==-1) 
     { 
      Print("Error in WebRequest. Error code  =",GetLastError()); 
      MessageBox("Add the address '"+url+"' to the list of allowed URLs on tab 'Expert Advisors'","Error",MB_ICONINFORMATION); 
     } 
   else 
     { 
      if(res==200) 
        { 
            result_str = CharArrayToString(result,0,WHOLE_ARRAY,CP_ACP);
            Print(result_str);
        } 
      else 
         PrintFormat("Downloading '%s' failed, error code %d",url,res); 
     }
  } 