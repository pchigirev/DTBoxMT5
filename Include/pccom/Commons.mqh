//+------------------------------------------------------------------+
//|                                                      Commons.mqh |
//|                                                   Pavel Chigirev |
//|                                        https://pavelchigirev.com |
//+------------------------------------------------------------------+
#property copyright "Pavel Chigirev"
#property link      "https://pavelchigirev.com"

//+------------------------------------------------------------------+

template<typename T> T StringToEnum(string str)
{
   for(int i = 0; i < 32767; i++)
   {
      T res = (T)i;
      if (EnumToString(res) == str)
         return(res);
   }
   return(-1);
}

//+------------------------------------------------------------------+

color StrToColor(string str)
{
   string rgb[];
   if (StringSplit(str, '-', rgb) == 3)
   {
      string strClr = rgb[0] + "," + rgb[1] + "," + rgb[2];
      color clr = StringToColor(strClr);
      return clr;
   }
   else
   {
      // Print warning
      // Return default
      return C'0,0,0';
   }
}

//+------------------------------------------------------------------+

string ColorToStr(color clr)
{
   string strClr = ColorToString(clr);
   string rgb[];
   StringSplit(strClr, ',', rgb);
   string res = rgb[0] + "-" + rgb[1] + "-" + rgb[2];
   return res;
}

//+------------------------------------------------------------------+