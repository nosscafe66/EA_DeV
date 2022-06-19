//+------------------------------------------------------------------+
//|                                                Cross_Madante.mq4 |
//|                                    Copyright 2022, YUTO KOUNOSU  |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2005-2014, MetaQuotes Software Corp."
#property link "http://www.mql4.com"
#property version "1.00"
//#property strict
#define MAGICMA 20228888
#property indicator_separate_window
#property indicator_minimum -90.0
#property indicator_maximum 90.0
#property indicator_buffers 1
#property indicator_color1 Blue

#property indicator_chart_window
#property indicator_color1 Yellow;  //D1 Low and High
#property indicator_color2 clrPeru; //H4 Low and High
#property indicator_color3 clrIndianRed; //H1 Low and High

//======各種フラグの説明=======
//基本的な上昇・下降の判定
//上昇：1、下降：2、何もしない：0
//基本的は買い注文、売り注文の判定
//買い：1、売り：2、何もしない：0
//通貨ペア取得フラグ
//通貨ペア取得できた：1、取得できない：0

//=======処理の順番について=======
//①NewCandleStickCheck()：新しいローソク足の判定処理
//②CandleStickCirculation()：ローソク足の確定後にエントリー条件の確認処理CrossMadantePerfectOrder()を実行
//③GlocalVariableUpdate()：の実行により取得した各種値をグローバル変数としてアップデートする処理
//④OrderFuncrion()：グローバル変数を格納後に注文処理
//⑤注文したポジションにたいていのオーダー確認処理、
//⑥ピラミッティング判定処理
//⑦損切り判定処理
//⑧利益確定処理
//上位足の水平線判定処理
//上位足のトレンドライン判定処理


//---- input parameters
extern int MovingAvaragePeriod = 25;
extern double BarWidth = 0.1;

//---- buffers
double ExtMapBuffer1[];

//LINE配信機能
input string Line_token = "";   // LINEのアクセストークン
input string Send_Message = ""; // LINEに送りたいメッセージ

//======グローバル変数として保持する値======

//移動平均線の値取得変数宣言(Ontickで取得した値が毎回更新される)
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

double pre_get_MA_5;
double pre_get_MA_14;
double pre_get_MA_21;
double pre_get_MA_60;
double pre_get_MA_240; 
double pre_get_MA_1440;

//一目均衡表の値取得宣言(Ontickで取得した値が毎回更新される)
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

//ローソク足の値取得宣言(Ontickで取得した値が毎回更新される)
double Candle_high;
double Candle_low;
double Candle_start;
double Candle_end;

double get_Candle_high;
double get_Candle_low;
double get_Candle_start;
double get_Candle_end;

//トレーリングストップ用のオーダーチェックフラグ
int OrderCheckBuyFlag = 0;
int OrderCheckSellFlag = 0;

int OrderCheckFlag;

//メッセージ変数宣言
string Message;

// 注文時の；チケット番号
int Ticket = 0;

// クロスマダンテの損切り値幅
int LossCut = 20;

//ロット管理
double Lots = OrderLots();

// 新しいローソク足の確認フラグ
int NewCandleStickCheckFlag;

//通貨ペアの変数宣言
string Currency;

//一度にエントリーできる通貨ペアの数の設定(最大5個まで)、この個数の中でループで条件判定を行う。
int EntryCurrencyCountMax = 5;

//現在のチャートID変数宣言
long now_id;
string filename;
int width;
int height;

//直近の高値と安値の変数宣言
double MostRecent_LowPrice;
double MostRecent_HighPrice;

//=======表示するチャートのカラー設定をする関数(クロスマダンテ仕様)=======
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

//=======業者間の通貨ペアの取得ができるようにする=======
//Pips業者間均一化機能
void PipsFunction()
{
double ticksize=MarketInfo(Symbol(),MODE_TICKSIZE);
   if(ticksize == 0.00001)
   {
   pips = ticksize*10;
   }
   else
   {
   pips = ticksize;
   }
return;
}

//通貨ペア業者間取得機能
string modifySymbol(string symbol)
{
  int length = StringLen(Symbol());
  string includedCharacter = "";
  if (length > 6)
  {
    includedCharacter = StringSubstr(Symbol(), 6, length - 6);
    // Print("通貨ペアは" + symbol + "サフィックスは" + includedCharacter + "です。"); //いずれ消す
    return (symbol + includedCharacter);
  }
  return (symbol);
}

//======================全通貨ペアに対して以下の設定を処理を判定する======================

//グローバル変数アップデートフラグ
int UpdateFlag;

//グローバル変数アップデート関数
int GlocalVariableUpdate(double get_MA_5, double get_MA_14, double get_MA_21, double get_MA_60, double get_MA_240, double get_MA_1440, double get_Tenkansen, double get_Kijunsen, double get_SenkouSpanA, double get_SenkouSpanB, double get_ChikouSpan, double get_Candle_high, double get_Candle_low, double get_Candle_start, double get_Candle_end)
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

//①//======================================================================
//連続でエントリーしないために
datetime time = Time[0];

//新しいローソク足の生成チェックフラグ
int NewCandleStickFlag;
int NewBar = 0;

//pipsの設定
double pips = 0;


int OnInit()
{
  //日足の水平線の値を表示するための設定
   ObjectDelete("D1 Low");   
   ObjectDelete("D1 High");      
   ObjectDelete("H4 Low");   
   ObjectDelete("H4 High");      
   ObjectDelete("H1 Low");   
   ObjectDelete("H1 High");

  //起動時に現在のバーを記録
  NewBar = Bars;
  setupChart();
  LineNotify(Line_token, Send_Message); // LineNotifyを呼び出し
  return (INIT_SUCCEEDED);
}

//処理が全て終了したら表示を削除する
int OnDeinit()
{

   ObjectDelete("D1 Low");   
   ObjectDelete("D1 High");      
   ObjectDelete("H4 Low");   
   ObjectDelete("H4 High");      
   ObjectDelete("H1 Low");   
   ObjectDelete("H1 High");      

   return 0;
}

double GetHorizenLine;

//上位足のトレンドライン判定処理
double GetHorizenLineFunction(int EntryOrderFlag){
//---
   int i=0;

   //Torday
   double d1_high=iHigh(NULL, PERIOD_D1,0); 
   double d1_low=iLow(NULL, PERIOD_D1,0);     
   
   if (Period() < PERIOD_D1) {  
      ObjectDelete("D1 Low");
      ObjectCreate("D1 Low",OBJ_HLINE, 0, Time[0], d1_low);
      ObjectSet("D1 Low", OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet("D1 Low", OBJPROP_COLOR, indicator_color1);
      ObjectSet("D1 Low", OBJPROP_WIDTH, 2);
      
      
      ObjectDelete("D1 High");
      ObjectCreate("D1 High",OBJ_HLINE, 0, Time[0], d1_high);
      ObjectSet("D1 High", OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet("D1 High", OBJPROP_COLOR, indicator_color1);      
      ObjectSet("D1 High", OBJPROP_WIDTH, 2);

   }

   //h4
   double h4_high = iHigh(NULL, PERIOD_H4,0);
   double h4_low  = iLow(NULL,PERIOD_H4,0);

   if (Period() < PERIOD_H4) {  
      ObjectDelete("H4 Low");
      ObjectCreate("H4 Low",OBJ_HLINE, 0, Time[0], h4_low);
      ObjectSet("H4 Low", OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet("H4 Low", OBJPROP_COLOR, indicator_color2);
      ObjectSet("H4 Low", OBJPROP_WIDTH, 2);
      
      ObjectDelete("H4 High");
      ObjectCreate("H4 High",OBJ_HLINE, 0, Time[0], h4_high);
      ObjectSet("H4 High", OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet("H4 High", OBJPROP_COLOR, indicator_color2);      
      ObjectSet("H4 High", OBJPROP_WIDTH, 2);
   }


   //h1
   double h1_high = iHigh(NULL, PERIOD_H1,0);
   double h1_low  = iLow(NULL,PERIOD_H1,0);

   if (Period() < PERIOD_H1) {  
      ObjectDelete("H1 Low");
      ObjectCreate("H1 Low",OBJ_HLINE, 0, Time[0], h1_low);
      ObjectSet("H1 Low", OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet("H1 Low", OBJPROP_COLOR, indicator_color3);
      ObjectSet("H1 Low", OBJPROP_WIDTH, 2);
      
      ObjectDelete("H1 High");
      ObjectCreate("H1 High",OBJ_HLINE, 0, Time[0], h1_high);
      ObjectSet("H1 High", OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet("H1 High", OBJPROP_COLOR, indicator_color3);      
      ObjectSet("H1 High", OBJPROP_WIDTH, 2);
   }
   if(EntryOrderFlag == 1){
      GetHorizenLine = h1_high;
   }else if(EntryOrderFlag == 2){
      GetHorizenLine = h1_low;
   }
   return(GetHorizenLine);
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
    stoploss = 0;
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
    stoploss = 0;
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

////ローソク足の陰陽確認フラグ
//int CandleStickCheck;
//
////ローソク足の陰陽確認関数(髭と実体の確認も行う)
//int CandleStickCheck()
//{
//}

//新規の売買注文を入れるための条件」と「決済注文を入れるための条件」
//現在ポジションがあるのか、そのポジションが「買い」なのか「売り」なのか
//ポジション判定：0(なし)、買い(1)、売り(2)
//注文数の確認フラグ

////注文確認関数
//int OrderCheck(int Ticket, int CandleStickFlag)
//{
//}
//
////ピラミッティング注文フラグ
//int PyramidingFlag;
//
////ピラミッティング注文関数(ピラミッティング注文をしたチケットとそうでないチケットを管理する処理も入れる。)
//int PyramidingOrder()
//{
//}

////決済判断フラグ
//int CloseCheckFlag;
////決済判断処理関数
//int CloseCheckFunction()
//{
//}

//現在の日足の
double d1_high=iHigh(NULL, PERIOD_D1,0); 
double d1_low=iLow(NULL, PERIOD_D1,0);  

int HorizonFlag;
//前日・前週の高値・安値を確認する処理
int HorizonCheckFunction(){
  //前日のローソク足の値取得
  double pre_Candle_D_high = iHigh(Currency, PERIOD_D1, 1);
  double pre_Candle_D_low = iLow(Currency, PERIOD_D1, 1);
  double pre_Candle_D_start = iOpen(Currency, PERIOD_D1, 1);
  double pre_Candle_D_end = iClose(Currency, PERIOD_D1, 1);

  //前週のローソク足の値取得
  double pre_Candle_W_high = iHigh(Currency, PERIOD_W1, 1);
  double pre_Candle_W_low = iLow(Currency, PERIOD_W1, 1);
  double pre_Candle_W_start = iOpen(Currency, PERIOD_W1, 1);
  double pre_Candle_W_end = iClose(Currency, PERIOD_W1, 1);

  //前日の日足の
  //if(){
  //
  //}
}

int TrendLineFlag;

//上位足のトレンドライン判定処理
int TrendLineCheckFlag(){

}


int EntryOrderFlag;
//クロスマダンテエントリー条件関数(パーフェクトオーダー判定処理)
int CrossMadantePerfectOrder(string Currency)
{
  //移動平均線の値を取得(一つ前)
  get_MA_5 = iMA(Currency, 0, 5, 0, MODE_SMA, PRICE_CLOSE, 1);
  get_MA_14 = iMA(Currency, 0, 14, 0, MODE_SMA, PRICE_CLOSE, 1);
  get_MA_21 = iMA(Currency, 0, 21, 0, MODE_SMA, PRICE_CLOSE, 1);
  get_MA_60 = iMA(Currency, 0, 60, 0, MODE_SMA, PRICE_CLOSE, 1);
  get_MA_240 = iMA(Currency, 0, 240, 0, MODE_SMA, PRICE_CLOSE, 1);
  get_MA_1440 = iMA(Currency, 0, 1440, 0, MODE_SMA, PRICE_CLOSE, 1);

  //移動平均線の値を取得(二つ前)
  pre_get_MA_5 = iMA(Currency, 0, 5, 0, MODE_SMA, PRICE_CLOSE, 2);
  pre_get_MA_14 = iMA(Currency, 0, 14, 0, MODE_SMA, PRICE_CLOSE, 2);
  pre_get_MA_21 = iMA(Currency, 0, 21, 0, MODE_SMA, PRICE_CLOSE, 2);
  pre_get_MA_60 = iMA(Currency, 0, 60, 0, MODE_SMA, PRICE_CLOSE, 2);
  pre_get_MA_240 = iMA(Currency, 0, 240, 0, MODE_SMA, PRICE_CLOSE, 2);
  pre_get_MA_1440 = iMA(Currency, 0, 1440, 0, MODE_SMA, PRICE_CLOSE, 2);

  //一目均衡表の値を取得(重要なのは先行スパンA,B=雲になる)
  get_Tenkansen = iCustom(Currency, 0, "Ichimoku", 9, 26, 52, 0, 1);
  get_Kijunsen = iCustom(Currency, 0, "Ichimoku", 9, 26, 52, 1, 1);
  get_SenkouSpanA = iCustom(Currency, 0, "Ichimoku", 9, 26, 52, 2, 1);
  get_SenkouSpanB = iCustom(Currency, 0, "Ichimoku", 9, 26, 52, 3, 1);
  get_ChikouSpan = iCustom(Currency, 0, "Ichimoku", 9, 26, 52, 4, 27);

  //ローソク足の値取得
  get_Candle_high = iHigh(Currency, PERIOD_M5, 1);
  get_Candle_low = iLow(Currency, PERIOD_M5, 1);
  get_Candle_start = iOpen(Currency, PERIOD_M5, 1);
  get_Candle_end = iClose(Currency, PERIOD_M5, 1);

  //実体の大きさと髭の大きさ
  double Candle_Entity;
  double Candle_Beard_Up;
  double Candle_Beard_Down;
  double Total_Candle;

  //実体と髭比率変数
  double Compare_Candle;

  //陽線判定処理
  double Positive_line = get_Candle_end - get_Candle_start;

  //陰線判定処理
  double Hidden_line = get_Candle_start - get_Candle_end;

  //移動平均線とローソク足の乖離を確認
  double Kairi_Value;

  //======前提条件確認：雲とローソク足の位置関係を判定し上昇トレンドか下降トレンドを判定する======
  /// OrderFlag が 1の時は上昇エントリー
  //上昇パーフェクトオーダー&全ての移動平均線が前回より大きい=傾きがある時のみの条件判定処理(大前提条件)
  if (get_MA_5 > get_MA_14 && get_MA_14 > get_MA_21 && get_MA_21 > get_MA_60 && get_MA_60 > get_MA_240 && get_MA_240 > get_MA_1440 &
    get_MA_5 > pre_get_MA_5 && get_MA_14 > pre_get_MA_14 && get_MA_21 > pre_get_MA_21 && get_MA_60 > pre_get_MA_60 && get_MA_240 > pre_get_MA_240 && get_MA_1440 > pre_get_MA_1440)
  {
    //ローソク足の雲の内外存在判定処理
    if (get_Candle_high > get_Candle_end && get_Candle_end > get_Candle_start && get_Candle_start > get_Candle_low && get_Candle_low > get_SenkouSpanA)
    {
      //確定したひとつ前のローソク足の陽線判定
      if (Positive_line > 0)
      {
        //陽線の実体と髭の比率を求める(髭の長さが50%以下)
        Candle_Entity = get_Candle_end - get_Candle_start;     //実体
        Candle_Beard_Up = get_Candle_high - get_Candle_end;    //上髭
        Candle_Beard_Down = get_Candle_start - get_Candle_low; //下髭
        Total_Candle = Candle_Entity + Candle_Beard_Up + Candle_Beard_Down;
        Compare_Candle = Candle_Beard_Up * 100 / Total_Candle; //実体と髭の比率を算定
        //ローソク足全体から髭長さが50%以下の際の判定処理(実体が多いローソク足)
        if (Compare_Candle < 50)
        {
          // 5SMAのローソク足陽線上抜け条件判定処理(例外として移動平均から乖離しすぎている場合はエントリーしない)
          Kairi_Value = (get_Candle_end - get_MA_5) * 100 / get_MA_5;
          if (get_Candle_high > get_Candle_end && get_Candle_end > get_MA_5 && Kairi_Value < 0.25)
          { 
            EntryOrderFlag = 1;
            Message = "Currency： " + Currency + ", OrderType： BUY" + ", Ticket番号：" + Ticket + ", 乖離率：" + Kairi_Value;
            //LineNotify(Line_token, Message);
            // Print("EntryOrderFlag :" + EntryOrderFlag); //いずれ消す
            //グローバル変数のアップデート関数呼び出し
            GlocalVariableUpdate(
                get_MA_5, get_MA_14, get_MA_21, get_MA_60, get_MA_240, get_MA_1440, get_Tenkansen, get_Kijunsen, get_SenkouSpanA, get_SenkouSpanB, get_ChikouSpan, get_Candle_high, get_Candle_low, get_Candle_start, get_Candle_end);
          }
        }
      }
    }
    else
    {
      EntryOrderFlag = 0;
      // Print("EntryOrderFlag :" + EntryOrderFlag);
      // GlocalVariableUpdate();
    }
  }
  //======上記で取得した処理フラグをもとに移動平均線とローソク足の位置関係を判定する======
  // OrderFlag が 2の時は下降エントリー
  //下降パーフェクトオーダーの条件判定処理
  else if (get_MA_5 < get_MA_14 && get_MA_14 < get_MA_21 && get_MA_21 < get_MA_60 && get_MA_60 < get_MA_240 && get_MA_240 < get_MA_1440 &
  get_MA_5 < pre_get_MA_5 && get_MA_14 < pre_get_MA_14 && get_MA_21 < pre_get_MA_21 && get_MA_60 < pre_get_MA_60 && get_MA_240 < pre_get_MA_240 && get_MA_1440 < pre_get_MA_1440
  )
  {
    //ローソク足の雲の内外存在判定処理
    if (get_Candle_low < get_Candle_end && get_Candle_end < get_Candle_start && get_Candle_start < get_Candle_high && get_Candle_high < get_SenkouSpanA)
    {
      Print("Hiddenline: " + Hidden_line);
      //確定したひとつ前のローソク足の陰線判定
      if (Hidden_line > 0)
      {
        //陰線の実体と髭の比率を求める(髭の長さが50%以下)
        Candle_Entity = get_Candle_start - get_Candle_end;    //実体
        Candle_Beard_Up = get_Candle_high - get_Candle_start; //上髭
        Candle_Beard_Down = get_Candle_end - get_Candle_low;  //下髭
        Total_Candle = Candle_Entity + Candle_Beard_Up + Candle_Beard_Down;
        Compare_Candle = Candle_Beard_Down * 100 / Total_Candle; //実体と髭の比率を算定

        //ローソク足全体から髭長さが50%以下の際の判定処理
        if (Compare_Candle < 50)
        {
          // 5SMAのローソク陰線下抜け条件判定処理(例外として移動平均から乖離しすぎている場合はエントリーしない)
          Kairi_Value = (get_MA_5 - get_Candle_end) * 100 / get_MA_5;
          Print("Kairi_Value: " + Kairi_Value);
          if (get_Candle_low < get_Candle_end && get_Candle_end > get_MA_5 && Kairi_Value < 0.25)
          {
            EntryOrderFlag = 2;
            Message = "Currency： " + Currency + ", OrderType： SELL" + ", Ticket番号：" + Ticket + ", 乖離率：" + Kairi_Value;
            //LineNotify(Line_token, Message);
            // Print("EntryOrderFlag :" + EntryOrderFlag); //いずれ消す
            //グローバル変数のアップデート関数呼び出し
            GlocalVariableUpdate(
                get_MA_5, get_MA_14, get_MA_21, get_MA_60, get_MA_240, get_MA_1440, get_Tenkansen, get_Kijunsen, get_SenkouSpanA, get_SenkouSpanB, get_ChikouSpan, get_Candle_high, get_Candle_low, get_Candle_start, get_Candle_end);
          }
        }
      }
    }
    else
    {
      EntryOrderFlag = 0;
      // Print("EntryOrderFlag :" + EntryOrderFlag);
      // GlocalVariableUpdate();
    }
  }
  //パーフェクトオーダーの条件を満たしていない場合
  // OrderFlag が 0の時は何もしない
  else
  {
    EntryOrderFlag = 0;
    // Print("EntryOrderFlag :" + EntryOrderFlag);
    //  GlocalVariableUpdate();
  }
  return (EntryOrderFlag);
}

////トレンド判定後エントリーフラグ
//int TrendJudgeFlag;
//
////トレンド判定関数
//int TrendJudgeCirculation()
//{
//}

// トレーリングストップのトレール幅
//買いポジションの場合、価格が上昇したら、その上昇した価格の20ポイント下にロスカットラインを引き上げる設定
double TrailingStop = 500;

int TraillingStopFunction(int CandleStickFlag, string Currency)
{
  int modified;
  double Max_Stop_Loss_Buy;
  double Max_Stop_Loss_Sell;
  double Current_Stop = OrderStopLoss();
  //未決済ポジションの判定処理を行う(取引中のポジション全てに対して確認する)
  Print("オーダートータル：" + OrdersTotal());
  //保有ポジションの数分だけ決済価格をへ変更する処理を追加する
  for (int OrderIndex = 0; OrderIndex < OrdersTotal(); OrderIndex++)
  {
    //トレードプールの中から一つのポジションを選択する。
    if(OrderSelect(OrderIndex-1,SELECT_BY_POS,MODE_TRADES)){
      //買いの未決済ポジション判定処理
      if (OrderType() == OP_BUY)
      {
        //買いの場合のフラグ設定
        OrderCheckBuyFlag = 1;
        //買い値からトレール幅の設定
        //Max_Stop_Loss_Buy = Bid - TrailingStop * Pips;
        Max_Stop_Loss_Buy = 200;
      }
      //売りの未決済ポジション判定処理
      if (OrderType() == OP_SELL)
      {
        //売りの場合のフラグ設定
        OrderCheckSellFlag = 2;
        //売り値からトレール幅の設定
        //Max_Stop_Loss_Sell = Ask + TrailingStop * Pips;
        Max_Stop_Loss_Sell = 200;
      }
    }

    //未決済買いポジションのトレーリングストップ(厳密にはトレールの幅を変更している処理)
    if (OrderCheckBuyFlag == 1)
    {
      if (TrailingStop > 0)
      {
        if (Bid - OrderOpenPrice() > Point * TrailingStop)
        {
          if (OrderStopLoss() < Bid - Point * Max_Stop_Loss_Buy)
          {
            Print("トレーリングストップ設定");
            Message = "トレーリングストップ：　Currency： " + Currency;
            //LineNotify(Line_token, Message);
            OrderModify(OrderTicket(), OrderOpenPrice(),Bid - Point * Max_Stop_Loss_Buy,OrderTakeProfit(),0,clrNONE);
          }
        }
      }
    }
    //未決済売りポジションのトレーリングストップ(厳密にはトレールの幅を変更している処理)
    if (OrderCheckSellFlag == 2)
    {
      if (TrailingStop > 0)
      {
        if ((OrderOpenPrice() - Ask) > (Point * TrailingStop))
        {
          if ((OrderStopLoss() > (Ask + Point * TrailingStop)) || (OrderStopLoss() == 0))
          {
            Print("トレーリングストップ設定");
            Message = "トレーリングストップ：　Currency： " + Currency;
            //LineNotify(Line_token, Message);
            OrderModify(OrderTicket(), OrderOpenPrice(), Max_Stop_Loss_Sell, 0, 0);
          }
        }
      }
    }
  }
}

//損切り設定関数(トレールと併用して設定する)
int LossCutFlag;
int LossCutFunction(int Ticket, int CandleStickFlag, string Currency)
{
  //ローソク足の値取得
  double LossCut_Candle_high = iHigh(Currency, PERIOD_M5, 1);
  double LossCut_Candle_low = iLow(Currency, PERIOD_M5, 1);
  double LossCut_Candle_start = iOpen(Currency, PERIOD_M5, 1);
  double LossCut_Candle_end = iClose(Currency, PERIOD_M5, 1);

  //double LossCut_MA_5 = iMA(Currency, 0, 5, 0, MODE_SMA, PRICE_CLOSE, 1);
  //double LossCut_MA_14 = iMA(Currency, 0, 14, 0, MODE_SMA, PRICE_CLOSE, 1);
  //double LossCut_MA_21 = iMA(Currency, 0, 21, 0, MODE_SMA, PRICE_CLOSE, 1);
  //double LossCut_MA_60 = iMA(Currency, 0, 60, 0, MODE_SMA, PRICE_CLOSE, 1);

  //先行スパンの値を取得する
  double LossCut_SenkouSpanA = iCustom(Currency, 0, "Ichimoku", 9, 26, 52, 2, 1);

  //陰線の判定処理
  double Hidden_line = get_Candle_start - get_Candle_end;
  
  //決済注文変数宣言
  bool orderClose;

  //損切り判定処理(5smaを陰線で完全に下抜けした場合)
  //陰線判定
  //約定した価格と現在の価格が一定以上乖離したら損切りを執行数する処理
  // Print("================================Hidden_line"+ Hidden_line);
  //買いポジションをを保有している場合の決済について、雲の中にローソク足が完全に潜った際に損切りを失効する
  Print("================================Hidden_line" + Hidden_line);
  if (LossCut_SenkouSpanA > LossCut_Candle_high && LossCut_Candle_high > LossCut_Candle_start && LossCut_Candle_start > LossCut_Candle_end && LossCut_Candle_end > LossCut_Candle_low)
  {
    Print("================================決済処理スタート===============================");
    //保有ポジションを一つずつチェックしていく
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
      Print("================================決済処理================================回数 :" + i);
      //保有ポジションを一つ選択
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
        //選択したポジションが、実行されている通貨ペアと同じかどうかチェック
        if (OrderSymbol() == Symbol())
        {
          //選択したポジションが、この自動売買のマジックナンバーと同じかチェック
          if (OrderMagicNumber() == MAGICMA)
          {
            //ポジションを決済
            orderClose = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 10, clrNONE);
          }
        }
      }
    }
  }
  //売りポジションをを保有している場合の決済について、雲の中にローソク足が完全に潜った際に損切りを失効する
  else if(LossCut_Candle_high > LossCut_Candle_end && LossCut_Candle_end > LossCut_Candle_start && LossCut_Candle_low > LossCut_Candle_low && LossCut_Candle_low > LossCut_SenkouSpanA){
    //保有ポジションを一つずつチェックしていく
    for (int j = OrdersTotal() - 1; j >= 0; j--)
    {
      Print("================================決済処理================================回数 :" + j);
      //保有ポジションを一つ選択
      if (OrderSelect(j, SELECT_BY_POS, MODE_TRADES))
      {
        //選択したポジションが、実行されている通貨ペアと同じかどうかチェック
        if (OrderSymbol() == Symbol())
        {
          //選択したポジションが、この自動売買のマジックナンバーと同じかチェック
          if (OrderMagicNumber() == MAGICMA)
          {
            //ポジションを決済
            orderClose = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 10, clrNONE);
          }
        }
      }
    }
  }
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

//メイン関数(値動きがあるたびに走る処理)
void OnTick()
{
  //通貨ペアの指定
  string ArraySymbol[6] = {"USDJPY"}; //希望としてはトレンドの発生しやすい通貨など、、手入力のパラメーターでもいい。

  //移動平均線&一目均衡表のエントリーフラグ
  int EntryOrderFlag;

  //通貨ペアのコメント表示
  Comment(modifySymbol(ArraySymbol[0]) + "¥n" + modifySymbol(ArraySymbol[1]) + "¥n" + modifySymbol(ArraySymbol[2]) + "¥n" + modifySymbol(ArraySymbol[3]) + "¥n" + modifySymbol(ArraySymbol[4])+ "¥n" + modifySymbol(ArraySymbol[5]));

  // Print("現在のポジション数" + OrdersTotal());
  //新しいローソク足ができていることを確認してから処理を開始
  NewCandleStickCheckFlag = NewCandleStickCheck(); //======関数1======
  if (NewCandleStickCheckFlag == 1)
  {
    //取得した通貨ペアの個数分エントリー条件の判定処理を実施する処理(想定では最大5回のループ処理)
    //配列に格納している通貨ペアの個数分(条件判定・エントリー判定の処理を行う、決済判定の処理を行う)
    for (int LoopCount = 0; LoopCount < ArraySize(ArraySymbol); LoopCount++)
    {
      //通貨ペアの名称取得
      Currency = modifySymbol(ArraySymbol[LoopCount]); //======関数2======
      //〜注文処理を実行する〜

      //クロスマダンテエントリー条件判定処理
      EntryOrderFlag = CrossMadantePerfectOrder(Currency); //======関数3======

      //上昇エントリーフラグ
      if (EntryOrderFlag == 1)
      {
        MostRecent_LowPrice = GetHorizenLineFunction(EntryOrderFlag);
        Print("現在の安値" + MostRecent_LowPrice);
        //オーダーが0から5つ以下のポジションの時に実行をする
        if (OrdersTotal() <= 5)
        {
          //注文処理(チケット発行)
          Ticket = OrderFuncrion(Currency, EntryOrderFlag);
          TraillingStopFunction(EntryOrderFlag, Currency);
          //トレーリングストップを設定してもなお未決済のポジションがある場合は損切りを失効する処理
          OrderCheckFlag = LossCutFunction(Ticket, EntryOrderFlag, Currency);
          //エラー処理
          if (Ticket != -1)
          {
            // OrderCheckFlag = OrderCheck(Ticket, EntryOrderFlag);
            OrderCheckFlag = LossCutFunction(Ticket, EntryOrderFlag, Currency);
            if (OrderCheckFlag == 0)
            {
              OrderFuncrion(Currency, EntryOrderFlag);
            }
          }
          else if (Ticket == -1)
          {
            // Print("チケット番号:" + Ticket + " UpEntryFailed:" + EntryOrderFlag); //いずれ消す
          }
        }
        //ポジション保有中の時の処理
        else if (OrdersTotal() >= 1)
        {
          // Print("トレーリングストップを設定するポジション数です。" + OrdersTotal());
          // Print("通貨ペアは" + Currency);
          // Print("エントリーフラグ" + EntryOrderFlag);
          // Print("================================決済処理================================");
          //トレーリングストップ処理
          TraillingStopFunction(EntryOrderFlag, Currency);
          //トレーリングストップを設定してもなお未決済のポジションがある場合は損切りを失効する処理
          OrderCheckFlag = LossCutFunction(Ticket, EntryOrderFlag, Currency);
        }
        else
        {
          // Print("ポジションの最大数に達しています。" + OrdersTotal());
          Comment(
              "\n",
              "オーダーが5以上のためエントリーなし");
          // Print("時間が同じためエントリー不可"); //いずれ消す
        }
      }
      //下降エントリーフラグ
      else if (EntryOrderFlag == 2)
      {
        MostRecent_HighPrice = GetHorizenLineFunction(EntryOrderFlag);
        Print("現在の高値" + MostRecent_HighPrice);
        // Print("DownEntryFlag:" + EntryOrderFlag); //いずれ消す
        //オーダーが0から5つ以下のポジションの時に実行をする
        if (OrdersTotal() <= 5)
        {
          //注文処理(チケット発行)
          Ticket = OrderFuncrion(Currency, EntryOrderFlag);
          TraillingStopFunction(EntryOrderFlag, Currency);
          //トレーリングストップを設定してもなお未決済のポジションがある場合は損切りを失効する処理
          OrderCheckFlag = LossCutFunction(Ticket, EntryOrderFlag, Currency);
          if (Ticket != -1)
          {
            // Print("チケット番号:" + Ticket + " DownEntryFlag:" + EntryOrderFlag); //いずれ消す
            //決済処理(雲の中に隠れてしまった場合・20pips固定のどちらかの条件に当てはまった場合に損切りを行う)
            // OrderCheckFlag = OrderCheck(Ticket, EntryOrderFlag);
            OrderCheckFlag = LossCutFunction(Ticket, EntryOrderFlag, Currency);
            if (OrderCheckFlag == 0)
            {
              OrderFuncrion(Currency, EntryOrderFlag);
            }
          }
          else if (Ticket == -1)
          {
            // Print("チケット番号:" + Ticket + " DownEntryFailed:" + EntryOrderFlag); //いずれ消す
          }
        }
        //ポジション保有中の時の処理
        else if (OrdersTotal() >= 1)
        {
          // Print("トレーリングストップを設定するポジション数です。" + OrdersTotal());
          // Print("通貨ペアは" + Currency);
          // Print("エントリーフラグ" + EntryOrderFlag);
          //トレーリングストップ処理
          TraillingStopFunction(EntryOrderFlag, Currency);
          //トレーリングストップを設定してもなお未決済のポジションがある場合は損切りを失効する処理
          OrderCheckFlag = LossCutFunction(Ticket, EntryOrderFlag, Currency);
        }
        else
        {
          // Print("ポジションの最大数に達しています。" + OrdersTotal());
          Comment(
              "\n",
              "オーダーが5以上のためエントリーなし");
          // Print("時間が同じためエントリー不可"); //いずれ消す
        }
      }
      else
      {
        // Print("NoEntry:" + EntryOrderFlag); //いずれ消す
      }
      //通貨の個数とループ回数がマッチしたらループを終了する処理
      if (LoopCount == ArraySize(ArraySymbol))
      {
        break;
      } // Print("処理終了"); //いずれ消す
      //ループ処理の終了
    }
  }
  else
  {
    Comment(
        "\n",
        "ノーエントリー");
    // Print("時間が同じためエントリー不可"); //いずれ消す
  }
  //------------------
}