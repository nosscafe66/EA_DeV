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
//クロスマダンテ条件
/*
・ロング：雲上
・ショート：雲下
・表示させる移動平均線：5.14.21.60.240.1440　全てパーフェクトオーダー
・5SMAをそれぞれ上抜け　下抜けでエントリー
・損切り：雲が入れ替わって反対側にいくか20pips固定、5分足での直近高値・安値少し上または下
・一番新しいローソク足が5EMAを抜けた時
・5分足のみ確認してエントリーする。
*/

datetime prevtime;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
  //---
  //---ー次のローソク足までの時間を表示する。
  ObjectCreate("TimerObj", OBJ_LABEL, 0, 0, 0);
  ObjectSetInteger(0, "TimerObj", OBJPROP_CORNER, CORNER_RIGHT_UPPER);
  ObjectSetInteger(0, "TimerObj", OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
  ObjectSetInteger(0, "TimerObj", OBJPROP_XDISTANCE, 0);
  ObjectSetInteger(0, "TimerObj", OBJPROP_YDISTANCE, 0);
  ObjectSetText("TimerObj", "", 24, "Meiryo UI", clrWhite);
  EventSetTimer(1);

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
  ObjectDelete("TimerObj");
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+

#property script_show_confirm 1
void OnTick()
{
  //--各種通貨ペアの値を取得--
  Print("通貨ペア " + _Symbol + "小数桁数 " + _Digits + "最小値幅" + _Point + "タイムフレーム " + _Period);

  int ticket;
  ticket = OrderSend(_Symbol, OP_BUY, 0.01, Ask, 3, 0, 0);
  // MessageBox("チケット番号" + ticket);
  Print("証拠金通貨：", AccountInfoString(ACCOUNT_CURRENCY));
  Print("レバレッジ：", AccountInfoInteger(ACCOUNT_LEVERAGE));
  Print("残高：", AccountInfoDouble(ACCOUNT_BALANCE));
  Print("有効証拠金：", AccountInfoDouble(ACCOUNT_EQUITY));
  Print("必要証拠金：", AccountInfoDouble(ACCOUNT_MARGIN));
  Print("余剰証拠金：", AccountInfoDouble(ACCOUNT_MARGIN_FREE));
  Print("証拠金維持率：", AccountInfoDouble(ACCOUNT_MARGIN_LEVEL));

  // EAの注文数
  int position = OrdersTotal();
  double ma = iMA(NULL, PERIOD_CURRENT, 20, 0, MODE_SMA, PRICE_CLOSE, 0);
  Print(ma);
  // 20pips乖離した場合、現在の売値よりも大きいASK(買い値)

  //〜処理①〜
  //--処理①_1--時間情報取得処理
  //--処理①_2--相場情報取得処理
  //--処理①_3--アカウント情報取得処理
  
  //〜処理②〜
  //--処理②--EA注文情報取得処理

  //--処理③--エントリー条件判定処理
  //--処理③_1--ー新しいローソク足ができているかどうかを確認する処理
  if (Time[0] != prevtime)
  {
    prevtime = Time[0];
  }

  //--処理③--

 //--処理④_1--一目均衡表とローソク足の位置判定
  if() {
    pass
  }else if {
    pass
  }else{
    pass
  }
  //--処理④_2--一目均衡表の値から雲の値を作成する。(先行スパンと遅行スパン)

  //--処理④_3--

  //--処理④_4--

  //--処理④_5--

  //--処理④_6--

  //一目均衡表の雲だけ出す。
  double Tenkansen = iCustom(NULL, 0, "Ichimoku", 9, 26, 52, 0, 1);
  double Kijunsen = iCustom(NULL, 0, "Ichimoku", 9, 26, 52, 1, 1);
  double SenkouSpanA = iCustom(NULL, 0, "Ichimoku", 9, 26, 52, 2, 1);
  double SenkouSpanB = iCustom(NULL, 0, "Ichimoku", 9, 26, 52, 3, 1);
  double ChikouSpan = iCustom(NULL, 0, "Ichimoku", 9, 26, 52, 4, 27);

  else
  {
    return (0);
  }

  if (position < 1)
  {
    if (ma - 0.2 >= Bid)
    {
      //(シンボル、注文方法、ロット数、買い値、スリッページ,SL、TP、コメント、EAのナンバリング、有効期限、カラー)
      //OrderSend(NULL, OP_BUY, 0.1, Ask, 0, Bid + 0.1, 0, "Long", 00000, 0, Red);//ロングエントリー
      //OrderSend(NULL, OP_BUY, 0.01, Ask, 0, Bid + 0.1, 0, "Short", 00000, 0, Red); //ショートエントリー
    }
    else if (ma - 0.2 <= Bid)
    {
      //OrderSend(NULL, OP_BUY, 0.01, Ask, 0, Bid + 0.1, 0, "Long", 00000, 0, Red);//ロングエントリー
      //OrderSend(NULL, OP_BUY, 0.01, Ask, 0, Bid + 0.1, 0, "Short", 00000, 0, Red); //ショートエントリー
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

void OnTimer()
{

  int secRemaining = Time[0] + PeriodSeconds() - TimeCurrent();
  int hour = secRemaining / 3600;
  int min = (secRemaining / 60) % 60;
  int sec = secRemaining - min * 60 - hour * 3600;

  string minStr = AddZero(min);
  string secStr = AddZero(sec);
  string TimeText;

  if (Period() <= 60)
  {
    TimeText = minStr + ":" + secStr;
  }
  else
  {
    TimeText = hour + ":" + minStr + ":" + secStr;
  }

  ObjectSetText("TimerObj", TimeText, 24);
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
  return (rates_total);
}

// 1秒を01秒にするための関数
string AddZero(int time)
{

  if (time > 0 && time < 10)
  {
    return "0" + (string)time;
  }
  else if (time <= 0)
  {
    return "00"; //ラグでマイナス秒になるのを防ぐ
  }
  else
  {
    return (string)time;
  }
}

//+------------------------------------------------------------------+