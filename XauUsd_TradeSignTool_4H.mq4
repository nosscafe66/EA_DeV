//+------------------------------------------------------------------+
//|                                   XaudUsd_TradingSignTool_4H.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2005-2014, MetaQuotes Software Corp."
#property link "http://www.mql4.com"
#property strict

//グローバル変数宣言
// xauusdのグローバル変数を宣言
string Currency = "";
int MaxOrder = 1;

// LINEアカウントへの通知設定
input string Line_token = "";   // LINEのアクセストークン
input string Send_Message = ""; // LINEに送りたいメッセージ

//連続でエントリーしないために
datetime time = Time[0];

//新しいローソク足の生成チェックフラグ
int NewCandleStickFlag;
int NewBar = 0;

void setupChart(long chartId = 0)
{
  // ローソク足で表示
  ChartSetInteger(chartId, CHART_MODE, CHART_CANDLES);

  // 買値 (Ask) ラインを表示
  ChartSetInteger(chartId, CHART_SHOW_ASK_LINE, true);
  ChartSetInteger(chartId, CHART_COLOR_BID, clrDodgerBlue);

  // 売値 (Bid) ラインを表示
  ChartSetInteger(chartId, CHART_SHOW_BID_LINE, true);
  ChartSetInteger(chartId, CHART_COLOR_ASK, clrOrangeRed);

  // 背景のグリッド線の設定表示
  ChartSetInteger(chartId, CHART_COLOR_GRID, clrNONE);

  // 背景のカラー設定表示
  ChartSetInteger(chartId, CHART_COLOR_BACKGROUND, clrBlack);

  // ローソク足の設定表示
  ChartSetInteger(chartId, CHART_COLOR_CHART_UP, clrBlue);
  ChartSetInteger(chartId, CHART_COLOR_CHART_DOWN, clrRed);
  ChartSetInteger(chartId, CHART_COLOR_CANDLE_BULL, clrBlue);
  ChartSetInteger(chartId, CHART_COLOR_CANDLE_BEAR, clrRed);

  // ChartSetInteger(chartId, , );
  // ChartSetInteger(chartId, , );
  // ChartSetInteger(chartId, , );
  // ChartSetInteger(chartId, , );
  // ChartSetInteger(chartId, , );

  ChartRedraw(chartId);
}

//通貨ペア取得関数
string modifySymbol(string symbol)
{
  int length = StringLen(Symbol());
  string includedCharacter = "";
  if (length > 6)
  {
    includedCharacter = StringSubstr(Symbol(), 6, length - 6);
    Print("通貨ペアは" + symbol + "サフィックスは" + includedCharacter + "です。"); //いずれ消す
    return (symbol + includedCharacter);
  }
  return (symbol);
}

//初期化処理
int OnInit()
{
  //--- create timer
  setupChart();
  EventSetTimer(14400);

  //---
  return (INIT_SUCCEEDED);
}

//新しいローソク足の生成チェック関数(凍結対策)
int NewCandleStickCheck()
{
  //連続でエントリーしないようにする
  // time変数が、現在の時間ではない場合に実行する
  if (time != Time[0])
  {
    // time変数に、現在の時間を代入
    time = Time[0];

    //エントリーロジックを実行するためのフラグ
    int iCurrentBars = Bars;
    if (iCurrentBars == NewBar)
    {
      NewBar = iCurrentBars;
      NewCandleStickFlag = 0;
      return (NewCandleStickFlag);
    }
    else
    {
      //バーの始まりで1回だけ処理したい内容をここに記載する
      //////エントリーロジック関数などを入れる
      //ここにロジックやエントリー注文を書く
      //エントリーサンプル（実行しないでください！！）
      // int buy = OrderSend(Symbol(), OP_BUY, LOT, Ask, 30, Ask-STOPLOSS_WIDTH, Ask+TAKEPROFIT_WIDTH, "自動売買を作ろう！", 9999, clrNONE);
      NewCandleStickFlag = 1;
      //今のバー数を記録
      NewBar = iCurrentBars;
    }
  }
  else
  {
    NewCandleStickFlag = 0;
  }
  return (NewCandleStickFlag);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
// void OnDeinit(const int reason)
//{
//  //--- destroy timer
//  EventKillTimer();
//}

int EntrySignFlag = 0;
int Sign_Tool_Xauusd_4H(string Currency)
{
  //ボリンジャーバンドの値を取得する変数宣言
  double Hensa = 2;

  //ローソク足の値を取得する変数宣言
  double get_Candle_high;
  double get_Candle_low;
  double get_Candle_start;
  double get_Candle_end;
  //ボリンジャーバンドミドルの値を取得する。
  double BoilngerMidleLine;
  double BoilngerMidle = 20;

  //実体の大きさと髭の大きさ
  double Candle_Entity;
  double Candle_Beard_Up;
  double Candle_Beard_Down;
  double Total_Candle;

  //実体と髭比率変数
  double Compare_Candle;

  //陽線判定処理
  double Positive_line;

  //陰線判定処理
  double Hidden_line;

  // 1つ前のボリンジャーバンドのミドルラインの値を取得する
  BoilngerMidleLine = iBands(Currency, 0, BoilngerMidle, Hensa, 0, PRICE_CLOSE, MODE_MAIN, 1);
  // 1本前の4時間のローソク足の値を取得する。
  get_Candle_high = iHigh(Currency, PERIOD_H4, 1);
  get_Candle_low = iLow(Currency, PERIOD_H4, 1);
  get_Candle_start = iOpen(Currency, PERIOD_H4, 1);
  get_Candle_end = iClose(Currency, PERIOD_H4, 1);

  //ローソク足の陽線と陰線を判定する処理
  Positive_line = get_Candle_end - get_Candle_start;
  Hidden_line = get_Candle_start - get_Candle_end;

  //エントリー条件の判定処理
  //ロングの条件
  //陽線の判定処理
  if (Positive_line > 0)
  {
    //陽線がBBミドルラインを実体で上に超える
    //①ローソク足が完全に超えた場合
    if (get_Candle_high > get_Candle_end && get_Candle_start > get_Candle_low && get_Candle_low > BoilngerMidleLine)
    {
      EntrySignFlag = 1;
      Print("上昇エントリーフラグ①" + EntrySignFlag);
      Comment(
          "\n",
          "上昇エントリーあり①");
    }
    //②高値と終値が超えた場合
    else if (get_Candle_high > get_Candle_end && get_Candle_end > BoilngerMidleLine)
    {
      EntrySignFlag = 1;
      Print("上昇エントリーフラグ②" + EntrySignFlag);
      Comment(
          "\n",
          "上昇エントリーあり②");
    }
    //それ以外の場合エントリーなし
    else
    {
      EntrySignFlag = 0;
      Print("上昇エントリーなし" + EntrySignFlag);
      Comment(
          "\n",
          "上昇エントリーなし");
    }
    //ショートの条件
    //陰線の判定処理
  }
  else if (Hidden_line > 0)
  {
    //陰線がBBミドルラインを実体で下に超える
    //①ローソク足が完全に超えた場合
    if (get_Candle_low < get_Candle_end && get_Candle_start < get_Candle_high && get_Candle_high > BoilngerMidleLine)
    {
      EntrySignFlag = 2;
      Print("下落エントリーフラグ①" + EntrySignFlag);
      Comment(
          "\n",
          "下落エントリーあり①");
    }
    //②安値と終値が超えた場合
    else if (get_Candle_low < get_Candle_end && get_Candle_end < BoilngerMidleLine)
    {
      EntrySignFlag = 2;
      Print("下落エントリーフラグ②" + EntrySignFlag);
      Comment(
          "\n",
          "下落エントリーあり②");
    }
    //それ以外の場合エントリーなし
    else
    {
      EntrySignFlag = 0;
      Print("下落エントリーなし" + EntrySignFlag);
      Comment(
          "\n",
          "オーダーなし");
    }
  }
  return (EntrySignFlag);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
  //---
  //現在のポジション数が1以下の時に処理を行う
  if (OrdersTotal() <= 1)
  {
    //現在のポジション数を把握する
    Print("現在のポジション数" + OrdersTotal());
    //ゴールドのペアを指定する。
    string ArraySymbol[3] = {"XAUUSD", "xauusd", "GOLD", "gold"};
    //ゴールドの通貨ペアの表記が業者により異なるためマッチした通貨でのエントリーを行う処理
    for (int LoopCount = 0; LoopCount < ArraySize(ArraySymbol); LoopCount++)
    {
      //ゴールド4時間足のエントリー条件確認処理
      // Print(ArraySymbol[LoopCount]);
      //エントリー条件判定処理
      Currency = modifySymbol(ArraySymbol[LoopCount]);
      if (Currency == ArraySymbol[LoopCount])
      {
        Sign_Tool_Xauusd_4H(Currency);
      }
    }
  }
}

//決済処理について
//損益0以上もしくは
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+

// 4時間ごとに処理を行う(正確には3時間30分が経過したあたりから確認を行う。)
void OnTimer()
{
  //---
}
//+------------------------------------------------------------------+