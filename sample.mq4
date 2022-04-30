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

//=======業者間の通貨ペアの取得ができるようにする=======
//サフィックスの設定
// string suffix;

//通貨ペア取得フラグ
// int GetCurrencyFlag;

//通貨ペア取得関数
string modifySymbol(string symbol)
{
  int length = StringLen(Symbol());
  string includedCharacter = "";
  if (length > 6)
  {
    includedCharacter = StringSubstr(Symbol(), 6, length - 6);
    Print("通貨ペアは" + symbol + "サフィックスは" + includedCharacter + "です。");
    return (symbol + includedCharacter);
  }
  return (symbol);
}

//一度にエントリーできる通貨ペアの数の設定(最大5個まで)、この個数の中でループで条件判定を行う。
int EntryCurrencyCountMax = 5;

//======================全通貨ペアに対して以下の設定を処理を判定する======================

//グローバル変数アップデートフラグ
int UpdateFlag;

//グローバル変数アップデート関数
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

//①//======================================================================
//連続でエントリーしないために
datetime time = Time[0];

//新しいローソク足の生成チェックフラグ
int NewCandleStickFlag;
int NewBar = 0;

int OnInit()
{
  //起動時に現在のバーを記録
  NewBar = Bars;
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
      return;
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

//注文処理関数
int OrderFuncrion(string Currency)
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
  if (CandleStickCirculation(Currency) == 1)
  {
    //買い注文設定
    symbol = Currency;
    cmd = "OP_BUY";
    volume = "0.1";
    price = "Ask";
    slippage = 3;
    stoploss = 0;
    takeprofit = 0;
    comment = "";
    magic = 20228888;
    expiration = 0;
    arrow_color = "Blue";
    Ticket = OrderSend(symbol, cmd, volume, price, slippage, stoploss, takeprofit, "", magic, expiration, arrow_color);
    OrderFlag = 1;
  }
  //下降エントリー設定処理
  else if (CandleStickCirculation(Currency) == 2)
  {
    //売り注文設定
    symbol = Currency;
    cmd = "OP_SELL";
    volume = "0.1";
    price = "Bid";
    slippage = 3;
    stoploss = 0;
    takeprofit = 0;
    comment = "";
    magic = 20228888;
    expiration = 0;
    arrow_color = "Red";
    Ticket = OrderSend(symbol, cmd, volume, price, slippage, stoploss, takeprofit, "", magic, expiration, arrow_color);
    OrderFlag = 2;
  }
  else
  {
    //注文しない
    OrderFlag = 0;
  }
  return (OrderFlag);
}

//ローソク足の陰陽確認フラグ
int CandleStickCheck;

//ローソク足の陰陽確認関数
int CandleStickCheck()
{
}

//注文数の確認フラグ
int OrderCheckFlag;

//注文確認関数
int OrderCheck()
{
}

//ピラミッティング注文フラグ
int PyramidingFlag;

//ピラミッティング注文関数(ピラミッティング注文をしたチケットとそうでないチケットを管理する処理も入れる。)
int PyramidingOrder()
{
}

//決済判断フラグ
int CloseCheckFlag;
//決済判断処理関数
int CloseCheckFunction()
{
}

//移動平均線&一目均衡表のフラグ
int EntryOrderFlag;

//エントリー条件関数(パーフェクトオーダー判定処理)
int CrossMadantePerfectOrder(string Currency)
{ //移動平均線の値を取得
  get_MA_5 = iMA(Currency, 0, 5, 0, MODE_SMA, PRICE_CLOSE, 1);
  get_MA_14 = iMA(Currency, 0, 14, 0, MODE_SMA, PRICE_CLOSE, 1);
  get_MA_21 = iMA(Currency, 0, 21, 0, MODE_SMA, PRICE_CLOSE, 1);
  get_MA_60 = iMA(Currency, 0, 60, 0, MODE_SMA, PRICE_CLOSE, 1);
  get_MA_240 = iMA(Currency, 0, 240, 0, MODE_SMA, PRICE_CLOSE, 1);
  get_MA_1440 = iMA(Currency, 0, 1440, 0, MODE_SMA, PRICE_CLOSE, 1);

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

  //======前提条件確認：雲とローソク足の位置関係を判定し上昇トレンドか下降トレンドを判定する======
  /// OrderFlag が 1の時は上昇エントリー
  if (get_Candle_high > get_Candle_end && get_Candle_end > get_Candle_start && get_Candle_start > get_Candle_low && get_Candle_low > get_SenkouSpanA && get_SenkouSpanA > get_SenkouSpanB)
  {
    EntryOrderFlag = 1;
    Print("EntryOrderFlag :" + EntryOrderFlag);
    //グローバル変数のアップデート関数呼び出し
    GlocalVariableUpdate();
  }
  //======上記で取得した処理フラグをもとに移動平均線とローソク足の位置関係を判定する======
  // OrderFlag が 2の時は下降エントリー
  else if (get_Candle_low < get_Candle_end && get_Candle_end < get_Candle_start && get_Candle_start < get_Candle_high && get_Candle_high < get_SenkouSpanA && get_SenkouSpanA < get_SenkouSpanB)
  {
    EntryOrderFlag = 2;
    Print("EntryOrderFlag :" + EntryOrderFlag);
    //グローバル変数のアップデート関数呼び出し
    GlocalVariableUpdate();
  }
  // OrderFlag が 0の時は何もしない
  else
  {
    EntryOrderFlag = 0;
    Print("EntryOrderFlag :" + EntryOrderFlag);
    GlocalVariableUpdate();
  }
  return (EntryOrderFlag);
}

//②//======================================================================
//ローソク足の判定条件
int CandleStickFlag;
//ローソク足の判定関数
int CandleStickCirculation(string Currency)
{ //上昇エントリー
  if (CrossMadantePerfectOrder(Currency) == 1)
  {
    CandleStickFlag = 1;
  }
  //下降エントリー
  else if (CrossMadantePerfectOrder(Currency) == 2)
  {
    CandleStickFlag = 2;
  }
  //ノーエントリー
  else if (CrossMadantePerfectOrder(Currency) == 0)
  {
    Comment(
        "\n",
        "ノーエントリー");
  }
}

//トレンド判定後エントリーフラグ
int TrendJudgeFlag;

//トレンド判定関数
int TrendJudgeCirculation()
{
}

//メイン関数(値動きがあるたびに走る処理)
void OnTick()
{

  //通貨ペアの指定
  string ArraySymbol[5] = {"USDJPY", "EURUSD", "GBPUSD", "GBPJPY", "AUDJPY"};
  //通貨ペアのコメント表示
  Comment(modifySymbol(ArraySymbol[0]) + "¥n" + modifySymbol(ArraySymbol[1]) + "¥n" + modifySymbol(ArraySymbol[2]) + "¥n" + modifySymbol(ArraySymbol[3]) + "¥n" + modifySymbol(ArraySymbol[4]));

  //新しいローソク足ができていることを確認する
  if (NewCandleStickCheck() == 1)
  {
    //取得した通貨ペアの個数分エントリー条件の判定処理を実施する処理(想定では最大5回のループ処理)
    Print("処理開始");
    //配列に格納している通貨ペアの個数分(条件判定・エントリー判定の処理を行う)
    for (int LoopCount = 0; LoopCount < ArraySize(ArraySymbol); LoopCount++)
    {
      Print("ループ回数：" + LoopCount + "回目です。 現在の通貨は" + ArraySymbol[LoopCount] + "です。");

      //通貨ペアの変数宣言
      string Currency;
      //通貨ペアの名称；取得
      Currency = modifySymbol(ArraySymbol[LoopCount]);
      //〜注文処理を実行する〜

      //ローソク足の判定処理
      CandleStickFlag = CandleStickCirculation(Currency);
      if (CandleStickFlag == 1)
      {
      }
      else if (CandleStickFlag == 2)
      {
      }
      else
      {
      }

      if (LoopCount == ArraySize(ArraySymbol))
      {
        break;
      }
    }
    Print("処理終了");
  }
  else
  {
    Comment(
        "\n",
        "ノーエントリー");
  }
  Print("ノーエントリー");
}