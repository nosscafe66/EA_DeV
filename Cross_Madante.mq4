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
  Print("Hello World");
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
  // EAの注文数
  int position = OrdersTotal();
  double ma = iMA(NULL, PERIOD_CURRENT, 20, 0, MODE_SMA, PRICE_CLOSE, 0);
  Print(ma);
  // 20pips乖離した場合、現在の売値よりも大きいASK(買い値)
  if (position < 1)
  {
    if (ma - 0.2 >= Bid)
    {
      //(シンボル、注文方法、ロット数、買い値、スリッページ,SL、TP、コメント、EAのナンバリング、有効期限、カラー)
      OrderSend(NULL, OP_BUY, 0.1, Ask, 0, Bid + 0.1, 0, "Long", 00000, 0, Red);
    }
    else if (ma - 0.2 <= Bid)
    {
      OrderSend(NULL, OP_BUY, 0.01, Ask, 0, Bid + 0.1, 0, "Long", 00000, 0, Red);
    }
  }
  else
  {
    if (OrderSelect(0, SELECT_BY_POS, MODE_TRADES) != false)
    {
      if (OrderType() == OP_BUY)
      {
        if (Bid >= ma)
        {
          OrderClose(OrderTicket(), OrderLots(), Bid, 0, Red);
        }
      }
      else if (OrderType() == OP_SELL)
      {
        if (Bid <= ma)
        {
          OrderClose(OrderTicket(), OrderLots(), Ask, 0, Blue);
        }
      }
    }
  }
}
//+------------------------------------------------------------------+