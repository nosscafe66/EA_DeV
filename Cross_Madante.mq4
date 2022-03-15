//+------------------------------------------------------------------+
//|                                                Cross_Madante.mq4 |
//|                                    Copyright 2022, YUTO KOUNOSU  |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link "https://www.mql5.com"
#property version "1.00"
#property strict
//--- input parameters

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
  //---
  Print("Cross Madnte");
  int num = 1;
  int num2 = 2;
  Print(num + num2);
  if (num == 1)
  {
    Print("OK");
    int sum = 0;
    for (int i = 0; i < 10; i++)
    {
      sum = 1 + i;
      if (sum == 5)
      {
        Print("End");
      }
    }
  }
  else if (num == 2)
  {
    Print("No");
  }

  //---
  return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
  //---
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
  //---
}
//+------------------------------------------------------------------+
