//+------------------------------------------------------------------+
//|                                   XaudUsd_TradingSignTool_4H.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link "https://www.mql5.com"
#property version "1.00"
#property strict
#define MAGICMA 20220000

//グローバル変数宣言
// xauusdのグローバル変数を宣言
string Currency = "";
int MaxOrder = 1;

// LINEアカウントへの通知設定
input string Line_token = "";   // LINEのアクセストークン
input string Send_Message = ""; // LINEに送りたいメッセージ

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
double BB2UP;
double BB2LO;

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

//連続でエントリーしないために
datetime time = Time[0];

//メッセージ変数宣言
string Message;

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
  // EventSetTimer(14400);
  LineNotify(Line_token, Send_Message); // LineNotifyを呼び出し

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

//注文処理フラグ
int OrderFlag;

//注文処理関数(チケットを発行する処理)
int OrderFuncrion(string Currency, int EntryOrderFlag)
{
  //注文フィールド(OrderSend関数実行に必要なパラメータ設定)
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
  int Ticket;

  ///上昇エントリー設定処理
  OrderFlag = EntryOrderFlag;
  if (OrderFlag == 1)
  {
    //買い注文設定
    symbol = Currency;
    cmd = OP_BUY;
    volume = 0.1; //関数化しておく
    price = Ask;
    slippage = 30;
    stoploss = 2;
    takeprofit = 0;
    comment = "";
    magic = MAGICMA;
    expiration = 0;
    arrow_color = clrBlue;
    Ticket = OrderSend(symbol, cmd, volume, price, slippage, stoploss, takeprofit, "", magic, expiration, arrow_color);
    OrderFlag = 1;
  }
  //下降エントリー設定処理
  else if (OrderFlag == 2)
  {
    //売り注文設定
    symbol = Currency;
    cmd = OP_SELL;
    volume = 0.1; //関数化しておく
    price = Bid;
    slippage = 30;
    stoploss = 2;
    takeprofit = 0;
    comment = "";
    magic = MAGICMA;
    expiration = 0;
    arrow_color = clrRed;
    Ticket = OrderSend(symbol, cmd, volume, price, slippage, stoploss, takeprofit, "", magic, expiration, arrow_color);
    OrderFlag = 2;
  }
  else
  {
    //注文しない
    OrderFlag = 0;
    // Print("NoEntry"); //いずれ消す
  }
  return (Ticket);
}

int EntrySignFlag = 0;
int Sign_Tool_Xauusd_4H(string Currency)
{

  // 1つ前のボリンジャーバンドのミドルラインの値を取得する
  BoilngerMidleLine = iBands(Currency, 1, BoilngerMidle, Hensa, 0, PRICE_CLOSE, MODE_MAIN, 1);
  BB2UP = iBands(Currency, 0, BoilngerMidle, 2, 0, PRICE_CLOSE, MODE_UPPER, 1);
  BB2LO = iBands(Currency, 0, BoilngerMidle, 2, 0, PRICE_CLOSE, MODE_LOWER, 1);
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
      Message = "Currency： " + Currency + ", OrderType： BUY";
      LineNotify(Line_token, Message);
      Comment(
          "\n",
          "上昇エントリーあり①");
    }
    //②高値と終値が超えた場合
    else if (get_Candle_high > get_Candle_end && get_Candle_end > BoilngerMidleLine)
    {
      EntrySignFlag = 1;
      Print("上昇エントリーフラグ②" + EntrySignFlag);
      Message = "Currency： " + Currency + ", OrderType： BUY";
      LineNotify(Line_token, Message);
      Comment(
          "\n",
          "上昇エントリーあり②");
    }
    //それ以外の場合エントリーなし
    else
    {
      EntrySignFlag = 0;
      Print("上昇エントリーなし" + EntrySignFlag);
      Message = "Currency： " + Currency + ", OrderType： BUY";
      LineNotify(Line_token, Message);
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
      Message = "Currency： " + Currency + ", OrderType： SELL";
      LineNotify(Line_token, Message);
      Comment(
          "\n",
          "下落エントリーあり①");
    }
    //②安値と終値が超えた場合
    else if (get_Candle_low < get_Candle_end && get_Candle_end < BoilngerMidleLine)
    {
      EntrySignFlag = 2;
      Print("下落エントリーフラグ②" + EntrySignFlag);
      Message = "Currency： " + Currency + ", OrderType： SELL";
      LineNotify(Line_token, Message);
      Comment(
          "\n",
          "下落エントリーあり②");
    }
    //それ以外の場合エントリーなし
    else
    {
      EntrySignFlag = 0;
      Print("下落エントリーなし" + EntrySignFlag);
      Message = "Currency： " + Currency + ", OrderType： SELL";
      LineNotify(Line_token, Message);
      Comment(
          "\n",
          "オーダーなし");
    }
  }
  return (EntrySignFlag);
}


// LINE配信機能
void LineNotify(string Token, string Message)
{
  string headers;        //ヘッダー
  char data[], result[]; //データ、結果

  headers = "Authorization: Bearer " + Token + "\r\n	application/x-www-form-urlencoded\r\n";
  ArrayResize(data, StringToCharArray("message=" + Message, data, 0, WHOLE_ARRAY, CP_UTF8) - 1);
  int res = WebRequest("POST", "https://notify-api.line.me/api/notify", headers, 0, data, data, headers);
  if (res == -1) //エラーの場合
  {
    Print("Error in WebRequest. Error code  =", GetLastError());
    MessageBox("Add the address 'https://notify-api.line.me' in the list of allowed URLs on tab 'Expert Advisors'", "Error", MB_ICONINFORMATION);
  }
}

//エントリー時のスクリーンショット機能
int piccount;
string filename = "CHARTPIC_" +piccount + ".png";
int width = 100;
int height = 100;
string ScreenShot;
long chartId = 0;
bool  ChartScreenShot(long chartId = 0,string filename,int width,int height,ENUM_ALIGN_MODE  align_mode = ALIGN_RIGHT);

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
  //---
  //連続エントリー禁止関数
  int NewCandleStickFlag = NewCandleStickCheck();
  //現在のポジション数が1以下の時に処理を行う
  if (NewCandleStickFlag == 1){
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
        if (Currency == "GOLD")
        {
          EntrySignFlag = Sign_Tool_Xauusd_4H(Currency);
          Print("エントリー通貨ペア" + Currency);
          Message = "Currency： " + Currency + ", OrderType： BUY";
          ScreenShot = ChartScreenShot(chartId,filename,width,height,ALIGN_CENTER);
          Message = Message + ScreenShot;
          LineNotify(Line_token, Message);
        }else if(Currency == "XAUUSD"){
          EntrySignFlag = Sign_Tool_Xauusd_4H(Currency);
          Print("エントリー通貨ペア" + Currency);
          Message = "Currency： " + Currency + ", OrderType： BUY";
          ScreenShot = ChartScreenShot(chartId,filename,width,height,ALIGN_CENTER);
          Message = Message + ScreenShot;
          LineNotify(Line_token, Message);
        }else if(Currency == "xauusd"){
          EntrySignFlag = Sign_Tool_Xauusd_4H(Currency);
          Print("エントリー通貨ペア" + Currency);
          Message = "Currency： " + Currency + ", OrderType： BUY";
          ScreenShot = ChartScreenShot(chartId,filename,width,height,ALIGN_CENTER);
          Message = Message + ScreenShot;
          LineNotify(Line_token, Message);
        }else{
          EntrySignFlag = Sign_Tool_Xauusd_4H(Currency);
          Print("エントリー通貨ペア" + Currency);
          Message = "Currency： " + Currency + ", OrderType： BUY";
          ScreenShot = ChartScreenShot(chartId,filename,width,height,ALIGN_CENTER);
          Message = Message + ScreenShot;
          LineNotify(Line_token, Message);
        }
      }
    }
  }else{
    Print("エントリーなし");
  }
}