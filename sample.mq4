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
//②CandleStickCirculation()：ローソク足の確定後にエントリー条件の確認処理EntryJudgeFunction()を実行
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
//string suffix;

//通貨ペア取得フラグ
int GetCurrencyFlag;

//通貨ペア取得関数
int GetCurrency(){
  string CurrencyComment;
  for (int CurrencyCount = 0;SymbolsTotal(false)-1; i++){
    //コメント処理で取得できていることを確認する========デバッグ処理
    CurrencyComment += SymbolName(CurrencyCount, false) +”\n”;
    //取得した通貨ペアを配列に格納する処理
    string CurrencyArray[];
    CurrencyArray += SymbolName(CurrencyCount, false);
    //通貨ペアを5個まで取得しておく処理
    if (CurrencyCount == 5)
    { 
      break;
    }
  }
  
  //取得した通貨ペアのサッフィクスを除いた名前を格納する配列
  string NewCurrencyArray[];

  //取得した通貨ペアの個数分のみループ処理でサフィックスを確認する処理
  for (int i = 0; i < ArraySize(CurrencyArray); i++)
  { 
    //=======取得した通貨のサフィックスを確認する処理=======
    //サフィックスなしの時の処理(USDJPY)
    if (StringLen(CurrencyArray[i]) < 6)
    {
      //取得した通貨ペアの名前をエキスパートアドバイザーに出力する処理(サフィックスなし=配列更新不要)
      Print(i + "取得した通貨ペアの名前は" + CurrencyArray[i] + "です。：サフィックスなし");
      //GetCurrencyFlag = 1;
    }
    //サフィックスありの時の処理(USDJPYmicroなど)
    else if (StringLen(CurrencyArray[i]) > 6)
    {
      //取得した通貨ペアの名前をエキスパートアドバイザーに出力する処理(サフィックスあり=配列要更新)
      Print(i + "取得した通貨ペアの名前は" + CurrencyArray[i] + "です。：サフィックスあり");
      
      //===========サフィックスを取り除く処理を追加する===========
      string symbol;
      string suffix;

      //通貨ペア名取得処理
      symbol = StringSubstr(CurrencyArray[i],0,6);
      //サフィックス取得処理
      suffix = StringSubstr(CurrencyArray[i], 6, StringLen(CurrencyArray[i]));
      Print(i + "取得した通貨ペアの名前は" + symbol + "です。：サフィックスは" + suffix + "です。");
      NewCurrencyArray += symbol[i]
      //GetCurrencyFlag = 2;
    }
    //それ以外の処理
    else
    { //注文も飛ばさない処理
      //GetCurrencyFlag = 0;
    }
  }
  //参照渡しもしくはそのまま配列を渡せる可能性もあるため、一旦この書き方にしておく。
  return (NewCurrencyArray);
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
int OrderFuncrion(){
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
  
  ///上昇エントリー設定処理
  if (CandleStickCirculation() == 1)
  {
    //買い注文設定
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
    //売り注文設定
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
  //OrderSend(Symbol(), OP_BUY, LotsOptimized(), Ask, 3, 0, 0, "", MAGICMA, 0, Blue);
  Ticket = OrderSend(symbol, cmd, volume, price, slippage, stoploss, takeprofit, "", 20228888, expiration, arrow_color);
  retrun (OrderFlag);
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
}

//決済判断フラグ
int CloseCheckFlag;
//決済判断処理関数
int CloseCheckFunction(){

}

    //移動平均線&一目均衡表のフラグ
    int OrderFlag;

//エントリー条件関数(パーフェクトオーダー判定処理)
int EntryJudgeFunction()
{ //移動平均線の値を取得
  get_MA_5 = iMA(_Symbol, 0, 5, 0, MODE_SMA, PRICE_CLOSE, 0);
  get_MA_14 = iMA(_Symbol, 0, 14, 0, MODE_SMA, PRICE_CLOSE, 0);
  get_MA_21 = iMA(_Symbol, 0, 21, 0, MODE_SMA, PRICE_CLOSE, 0);
  get_MA_60 = iMA(_Symbol, 0, 60, 0, MODE_SMA, PRICE_CLOSE, 0);
  get_MA_240 = iMA(_Symbol, 0, 240, 0, MODE_SMA, PRICE_CLOSE, 0);
  get_MA_1440 = iMA(_Symbol, 0, 1440, 0, MODE_SMA, PRICE_CLOSE, 0);

  //一目均衡表の値を取得(重要なのは先行スパンA,B=雲になる)
  get_Tenkansen = iCustom(_Symbol, 0, "Ichimoku", 9, 26, 52, 0, 1);
  get_Kijunsen = iCustom(_Symbol, 0, "Ichimoku", 9, 26, 52, 1, 1);
  get_SenkouSpanA = iCustom(_Symbol, 0, "Ichimoku", 9, 26, 52, 2, 1);
  get_SenkouSpanB = iCustom(_Symbol, 0, "Ichimoku", 9, 26, 52, 3, 1);
  get_ChikouSpan = iCustom(_Symbol, 0, "Ichimoku", 9, 26, 52, 4, 27);

  //ローソク足の値取得
  get_Candle_high = iHigh(_Symbol, PERIOD_M5, 0);
  get_Candle_low = iLow(_Symbol, PERIOD_M5, 0);
  get_Candle_start = iOpen(_Symbol, PERIOD_M5, 0);
  get_Candle_end = iClose(_Symbol, PERIOD_M5, 0);

  //======前提条件確認：雲とローソク足の位置関係を判定し上昇トレンドか下降トレンドを判定する======
  /// OrderFlag が 1の時は上昇エントリー
  if (get_Candle_high > get_Candle_end && get_Candle_end > get_Candle_start && get_Candle_start > get_Candle_low && get_Candle_low > get_SenkouSpanA && get_SenkouSpanA > get_SenkouSpanB)
  {
    OrderFlag = 1;
    Print("EntryFlag :" + OrderFlag);
    //グローバル変数のアップデート関数呼び出し
    GlocalVariableUpdate();
  }
  //======上記で取得した処理フラグをもとに移動平均線とローソク足の位置関係を判定する======
  // OrderFlag が 2の時は下降エントリー
  else if (get_Candle_low < get_Candle_end && get_Candle_end < get_Candle_start && get_Candle_start < get_Candle_high && get_Candle_high < get_SenkouSpanA && get_SenkouSpanA < get_SenkouSpanB)
  {
    OrderFlag = 2;
    Print("EntryFlag :" + OrderFlag);
    //グローバル変数のアップデート関数呼び出し
    GlocalVariableUpdate();
  }
  // OrderFlag が 0の時は何もしない
  else
  {
    OrderFlag = 0;
    Print("EntryFlag :" + OrderFlag);
    GlocalVariableUpdate();
  }
  return (OrderFlag);
}

//ローソク足の判定条件
int CandleStickFlag;
//ローソク足の判定関数
int CandleStickCirculation()
{ //上昇エントリー
  if (EntryJudgeFunction() == 1)
  {
    //注文関数の呼び出し処理(上昇エントリー)
    //OrderSend(Symbol(), OP_BUY, LotsOptimized(), Ask, 3, 0, 0, "", MAGICMA, 0, Blue);
    CandleStickFlag = 1;
  }
  //下降エントリー
  else if (EntryJudgeFunction() == 2)
  {
    //注文関数の呼び出し処理(下降エントリー)
    CandleStickFlag = 2;
    // OrderSend(Symbol(),OP_SELL,LotsOptimized(),Bid,3,0,0,"",MAGICMA,0,Red);
  }
  //ノーエントリー
  else if (EntryJudgeFunction() == 0)
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
  if (NewCandleStickCheck() == 1)
  { 
    //取得した通貨ペアの個数分エントリー条件の判定処理を実施する処理(想定では最大5回のループ処理)
    Print("処理開始")
    for (int LoopCount = 0; i < ArraySize(GetCurrency());)
    {
      CandleStickCirculation();
      Print("ループ回数：" + LoopCount + "回目です。")
      if(LoopCount == 5){
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