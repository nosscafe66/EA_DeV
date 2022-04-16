//+------------------------------------------------------------------+
//|                                                Cross_Madante.mq4 |
//|                                    Copyright 2022, YUTO KOUNOSU  |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2005-2014, MetaQuotes Software Corp."
#property link "http://www.mql4.com"
//#property version "1.00"
//#property strict
#define MAGICMA 20228888

double MA_5;
double MA_14;
double MA_21;
double MA_60;
double MA_240;
double MA_1440;

double get_MA_5;
double get_MA_14;
double get_MA_21;
double get_MA_60;
double get_MA_240;
double get_MA_1440;

double Tenkansen;
double Kijunsen;
double SenkouSpanA;
double SenkouSpanB;
double ChikouSpan;

double get_Tenkansen;
double get_Kijunsen;
double get_SenkouSpanA;
double get_SenkouSpanB;
double get_ChikouSpan;

double Candle_high;
double Candle_low;
double Candle_start;
double Candle_end;

double get_Candle_high;
double get_Candle_low;
double get_Candle_start;
double get_Candle_end;

int GetCurrencyFlag;

int GetCurrency()
{
  string CurrencyComment;
  for (int CurrencyCount = 0; SymbolsTotal(false) - 1; i++)
  {
    CurrencyComment += SymbolName(CurrencyCount, false) +”\n”;
    string CurrencyArray[];
    CurrencyArray += SymbolName(CurrencyCount, false);
    if (CurrencyCount == 5)
    {
      break;
    }
  }
  string NewCurrencyArray[];
  for (int i = 0; i < ArraySize(CurrencyArray); i++)
  {
    if (StringLen(CurrencyArray[i]) < 6)
    {
      Print(i + "取得した通貨ペアの名前は" + CurrencyArray[i] + "です。：サフィックスなし");
      // GetCurrencyFlag = 1;
    }
    else if (StringLen(CurrencyArray[i]) > 6)
    {
      Print(i + "取得した通貨ペアの名前は" + CurrencyArray[i] + "です。：サフィックスあり");

      string symbol;
      string suffix;
      symbol = StringSubstr(CurrencyArray[i], 0, 6);
      suffix = StringSubstr(CurrencyArray[i], 6, StringLen(CurrencyArray[i]));
      Print(i + "取得した通貨ペアの名前は" + symbol + "です。：サフィックスは" + suffix + "です。");
      NewCurrencyArray += symbol[i]
      // GetCurrencyFlag = 2;
    }
    else
    {
      // GetCurrencyFlag = 0;
    }
  }
  return (NewCurrencyArray);
}

int UpdateFlag;
int GlocalVariableUpdate()
{
  MA_5 = get_MA_5;
  MA_14 = get_MA_14;
  MA_21 = get_MA_21;
  MA_60 = get_MA_60;
  MA_240 = get_MA_240;
  MA_1440 = get_MA_1440;
  Tenkansen = get_Tenkansen;
  Kijunsen = get_Kijunsen;
  SenkouSpanA = get_SenkouSpanA;
  SenkouSpanB = get_SenkouSpanB;
  ChikouSpan = get_ChikouSpan;
  Candle_high = get_Candle_high;
  Candle_low = get_Candle_low;
  Candle_start = get_Candle_start;
  Candle_end = get_Candle_end;

  Comment(
      "\n",
      " 5移動平均線：", MA_5, "\n", "\n",
      "14移動平均線：", MA_14, "\n", "\n",
      "21移動平均線：", MA_21, "\n", "\n",
      "60移動平均線：", MA_60, "\n", "\n",
      "240移動平均線：", MA_240, "\n", "\n",
      "1440移動平均線：", MA_1440,
      "転換線", Tenkansen, "\n", "\n",
      "基準線", Kijunsen, "\n", "\n",
      "先行スパンA", SenkouSpanA, "\n", "\n",
      "先行スパンB", SenkouSpanB, "\n", "\n",
      "遅行スパン", ChikouSpan, "\n", "\n",
      "高値", Candle_high, "\n", "\n",
      "安値", Candle_low, "\n", "\n",
      "始値", Candle_start, "\n", "\n",
      "終値", Candle_end);
  UpdateFlag = 1;
  return (UpdateFlag);
}

datetime time = Time[0];
int NewCandleStickFlag;
int NewBar = 0;

int OnInit()
{
  NewBar = Bars;
}

int NewCandleStickCheck()
{
  if (time != Time[0])
  {
    time = Time[0];
    int iCurrentBars = Bars;
    if (iCurrentBars == NewBar)
    {
      NewBar = iCurrentBars;
      return;
    }
    else
    {
      NewCandleStickFlag = 1;
      NewBar = iCurrentBars;
    }
  }
  else
  {
    NewCandleStickFlag = 0;
  }
  return (NewCandleStickFlag);
}
int OrderFlag;

int OrderFuncrion()
{

  string symbol;
  int cmd;
  double volume;
  double price;
  int slippage;
  double stoploss;
  double takeprofit;
  string comment;
  int magic;
  datetime expiration;
  color arrow_color;

  if (CandleStickCirculation() == 1)
  {

    symbol =
    cmd =
    volume =
    price =
    slippage =
    stoploss =
    takeprofit =
    comment =
    magic =
    expiration =
    arrow_color =
    OrderFlag = 1;
  }
  //下降エントリー設定処理
  else if (CandleStickCirculation() == 2)
  {
    symbol =
    cmd =
    volume =
    price =
    slippage =
    stoploss =
    takeprofit =
    comment =
    magic =
    expiration =
    arrow_color =
    OrderFlag = 2;
  }
  else
  {
    //注文しない
    OrderFlag = 0;
  }
  Ticket = OrderSend(symbol, cmd, volume, price, slippage, stoploss, takeprofit, "", 20228888, expiration, arrow_color);
  retrun(OrderFlag);
}

int CandleStickCheck;
int CandleStickCheck()
{
}

int OrderCheckFlag;
int OrderCheck()
{
}

int PyramidingFlag;
int PyramidingOrder()
}

int OrderFlag;
int EntryJudgeFunction()
{ 
  get_MA_5 = iMA(_Symbol, 0, 5, 0, MODE_SMA, PRICE_CLOSE, 0);
  get_MA_14 = iMA(_Symbol, 0, 14, 0, MODE_SMA, PRICE_CLOSE, 0);
  get_MA_21 = iMA(_Symbol, 0, 21, 0, MODE_SMA, PRICE_CLOSE, 0);
  get_MA_60 = iMA(_Symbol, 0, 60, 0, MODE_SMA, PRICE_CLOSE, 0);
  get_MA_240 = iMA(_Symbol, 0, 240, 0, MODE_SMA, PRICE_CLOSE, 0);
  get_MA_1440 = iMA(_Symbol, 0, 1440, 0, MODE_SMA, PRICE_CLOSE, 0);

  get_Tenkansen = iCustom(_Symbol, 0, "Ichimoku", 9, 26, 52, 0, 1);
  get_Kijunsen = iCustom(_Symbol, 0, "Ichimoku", 9, 26, 52, 1, 1);
  get_SenkouSpanA = iCustom(_Symbol, 0, "Ichimoku", 9, 26, 52, 2, 1);
  get_SenkouSpanB = iCustom(_Symbol, 0, "Ichimoku", 9, 26, 52, 3, 1);
  get_ChikouSpan = iCustom(_Symbol, 0, "Ichimoku", 9, 26, 52, 4, 27);

  get_Candle_high = iHigh(_Symbol, PERIOD_M5, 0);
  get_Candle_low = iLow(_Symbol, PERIOD_M5, 0);
  get_Candle_start = iOpen(_Symbol, PERIOD_M5, 0);
  get_Candle_end = iClose(_Symbol, PERIOD_M5, 0);

  if (get_Candle_high > get_Candle_end && get_Candle_end > get_Candle_start && get_Candle_start > get_Candle_low && get_Candle_low > get_SenkouSpanA && get_SenkouSpanA > get_SenkouSpanB)
  {
    OrderFlag = 1;
    Print("EntryFlag :" + OrderFlag);
    GlocalVariableUpdate();
  }
  else if (get_Candle_low < get_Candle_end && get_Candle_end < get_Candle_start && get_Candle_start < get_Candle_high && get_Candle_high < get_SenkouSpanA && get_SenkouSpanA < get_SenkouSpanB)
  {
    OrderFlag = 2;
    Print("EntryFlag :" + OrderFlag);
    GlocalVariableUpdate();
  }
  else
  {
    OrderFlag = 0;
    Print("EntryFlag :" + OrderFlag);
    GlocalVariableUpdate();
  }
  return (OrderFlag);
}
int CandleStickFlag;
int CandleStickCirculation()
{ 
  if (EntryJudgeFunction() == 1)
  {
    CandleStickFlag = 1;
  }
  else if (EntryJudgeFunction() == 2)
  {
    CandleStickFlag = 2;
  }
  else if (EntryJudgeFunction() == 0)
  {
    Comment(
        "\n",
        "ノーエントリー");
  }
}

int TrendJudgeFlag;
int TrendJudgeCirculation()
{
}

void OnTick()
{
  if (NewCandleStickCheck() == 1)
  {
    Print("処理開始") for (int LoopCount = 0; i < ArraySize(GetCurrency());)
    {
      CandleStickCirculation();
      Print("ループ回数：" + LoopCount + "回目です。") if (LoopCount == 5)
      {
        break;
      }
    }
    Print("処理終了")
  }
  else
  {
    Comment(
        "\n",
        "ノーエントリー");
  }
}