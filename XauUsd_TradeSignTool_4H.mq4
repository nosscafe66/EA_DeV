//+------------------------------------------------------------------+
//|                                   XaudUsd_TradingSignTool_4H.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property strict

//グローバル変数宣言
//xauusdのグローバル変数を宣言
string Currency = "";
int MaxOrder = 1;

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
  }else if(length)
  return (symbol);
}




//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   
  }

int EntrySignFlag = 0;
int Sign_Tool_Xauusd_4H(string Currency){

  //ボリンジャーバンドの値を取得する変数宣言
  double Hensa = 1;
  double MaTerm = 20;

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

  //1つ前のボリンジャーバンドのミドルラインの値を取得する
  BoilngerMidleLine = iBands(Currency, , BoilngerMidle, Hensa, 0, PRICE_CLOSE, MODE_MAIN, 1);
  // 1本前の4時間のローソク足の値を取得する。
  get_Candle_high = iHigh(Currency, PERIOD_H4, 1);
  get_Candle_low = iLow(Currency, PERIOD_H4, 1);
  get_Candle_start = iOpen(Currency, PERIOD_H4, 1);
  get_Candle_end = iClose(Currency, PERIOD_H4, 1);

  //ローソク足の陽線と陰線を判定する処理
  Positive_line = get_Candle_end - get_Candle_start;
  Hidden_line = get_Candle_start - get_Candle_end

  //エントリー条件の判定処理

  //ロングの条件
  //陽線の判定処理
  if(Positive_line > 0){
    //陽線がBBミドルラインを実体で上に超える
    //①ローソク足が完全に超えた場合
    if (get_Candle_high > get_Candle_end && get_Candle_start > get_Candle_low && get_Candle_low > BoilngerMidleLine)
    {
      EntrySignFlag = 1;
    }
    //②高値と終値が超えた場合
    else if (get_Candle_high > get_Candle_end && get_Candle_end > BoilngerMidleLine)
    {
      EntrySignFlag = 1;
    }
    //それ以外の場合エントリーなし
    else{
      EntrySignFlag = 0;
    }
  }


  //ショートの条件
  //陰線の判定処理
  if (Hidden_line > 0){
    //陰線がBBミドルラインを実体で下に超える
    //①ローソク足が完全に超えた場合
    if (get_Candle_low < get_Candle_end && get_Candle_start < get_Candle_High && get_Candle_high > BoilngerMidleLine)
    {
      EntrySignFlag = 2;
    }
    //②安値と終値が超えた場合
    else if (get_Candle_low < get_Candle_end && get_Candle_end < BoilngerMidleLine)
    {
      EntrySignFlag = 2;
    }
    //それ以外の場合エントリーなし
    else{
      EntrySignFlag = 0;
    }
  }
}



//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
//現在のポジション数が1以下の時に処理を行う
    if (OrdersTotal() <= 1){
      //現在のポジション数を把握する
      Print("現在のポジション数" + OrdersTotal());

      //ゴールドのペアを指定する。
      string ArraySymbol[3] = {"XAUUSD", "xauusd", "GOLD", "gold"};

      //ゴールドの通貨ペアの表記が業者により異なるためマッチした通貨でのエントリーを行う処理
      for (int LoopCount = 0; LoopCount < ArraySize(ArraySymbol); LoopCount++){
        //ゴールド4時間足のエントリー条件確認処理
        Print(ArraySymbol[i]);
      }
    }
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+

//4時間ごとに処理を行う(正確には3時間30分が経過したあたりから確認を行う。)
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
