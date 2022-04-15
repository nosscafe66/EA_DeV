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

//--- input parameters
input double Lots = 0.01;            //ロット数の設定
input double MAXLOT = 1;             //最大ロット数の設定
input double MAXPOSITION = 200;      //最大ポジション数
input double TAKEPROFIT_WIDTH = 100; //利確幅（単位point）
input double STOPLOSS_WIDTH = 100;   //損切り幅（単位point）
input double MaximumRisk = 0.02;
input double DecreaseFactor = 3;
input int MovingPeriod = 12;
input int MovingShift = 6;

//======グローバル変数として保持する値======

//移動平均線の値取得変数宣言(Ontickで取得した値が毎回更新される)
double MA_5;
double MA_14;
double MA_21;
double MA_60;
double MA_240;
double MA_1440;

//一目均衡表の値取得宣言(Ontickで取得した値が毎回更新される)
double Tenkansen;
double Kijunsen;
double SenkouSpanA;
double SenkouSpanB;
double ChikouSpan;

//ローソク足の値取得宣言(Ontickで取得した値が毎回更新される)
double Candle_high;
double Candle_low;
double Candle_start;
double Candle_end;

//=======業者間の通貨ペアの取得ができるようにする=======
//サフィックスの設定
string suffix;

//連続でエントリーしないためのフラグ
datetime time = Time[0];

// Print("HELLO LONG");

// CrossMadante用マジックナンバーの設定(自動売買がポジションを管理するための番号)

int orderFlag = 0; //エントリーするかどうかの初期値
// int orderTotal;//注文数の初期値

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
  //---
  //---グローバル変数の初期化

  //======インジケーターの可視化======

  //---
  return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
// void OnDeinit(const int reason)
//{
//---
//}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+

#property script_show_confirm 1

double LotsOptimized()
{
  double lot = Lots;
  int orders = HistoryTotal(); // history orders total
  int losses = 0;              // number of losses orders without a break
                               //--- select lot size
  lot = NormalizeDouble(AccountFreeMargin() * MaximumRisk / 1000.0, 1);
  //--- calcuulate number of losses orders without a break
  if (DecreaseFactor > 0)
  {
    for (int i = orders - 1; i >= 0; i--)
    {
      if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) == false)
      {
        Print("Error in history!");
        break;
      }
      if (OrderSymbol() != Symbol() || OrderType() > OP_SELL)
        continue;
      //---
      if (OrderProfit() > 0)
        break;
      if (OrderProfit() < 0)
        losses++;
    }
    if (losses > 1)
      lot = NormalizeDouble(lot - lot * losses / DecreaseFactor, 1);
  }
  //--- return lot size
  if (lot < 0.1)
    lot = 0.1;
  return (lot);
}

//初期関数(価格が動くごとに実行)
void OnTick()
{
  //--
  // OrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,3,0,0,"",MAGICMA,0,Blue);
  //現在のポジション数を代入する変数
  int positionNum = 0;

  //ここに現在のポジション数を更新するプログラムを書く

  //最大ロット数のチェック
  // if (Lots > MAXLOT)
  //  Print(MAXLOT);
  // return;

  //最大ポジション数のチェック
  // if (positionNum > MAXPOSITION)
  //  Print(MAXPOSITION);
  // return;

  //連続でエントリーしないようにする処理
  // time変数が、現在の時間ではない場合に実行する
  // if (time != Time[0])
  // {

  // time変数に、現在の時間を代入
  // time = Time[0];

  //↓↓↓↓↓↓↓↓↓↓↓↓ここから下にロジックやエントリー注文を書く↓↓↓↓↓↓↓↓↓↓↓↓
  //=======Cross_Madante用のエントリーロジック======

  //エントリーサンプル（実行しない）
  // int buy = OrderSend(Symbol(), OP_BUY, LOT, Ask, 30, Ask-STOPLOSS_WIDTH, Ask+TAKEPROFIT_WIDTH, "自動売買を作ろう！", magicNumber, clrNONE);

  //=====移動平均線の値を取得する処理======

  //現在の移動平均線の値と比較を行い,前回の値を下回ったら値を取得する.前回と同じかそれ以上の場合は値を更新しない.

  //======陽線と陰線の判定======
  //陽線======終値 > 始値：終値 – 始値・上髭の長さについて：高値 – 終値・下髭の長さについて：始値 – 安値
  //陽線======始値 > 終値：始値 – 終値・上髭の長さについて：高値 – 始値・下髭の長さについて：終値 – 安値

  //======移動平均線・一目均衡表・ローソク足の取得変数
  // if ()
  //{ //移動平均線の値を取得
  double get_MA_5 = iMA(NULL, 0, 5, 0, MODE_SMA, PRICE_CLOSE, 0);
  double get_MA_14 = iMA(NULL, 0, 14, 0, MODE_SMA, PRICE_CLOSE, 0);
  double get_MA_21 = iMA(NULL, 0, 21, 0, MODE_SMA, PRICE_CLOSE, 0);
  double get_MA_60 = iMA(NULL, 0, 60, 0, MODE_SMA, PRICE_CLOSE, 0);
  double get_MA_240 = iMA(NULL, 0, 240, 0, MODE_SMA, PRICE_CLOSE, 0);
  double get_MA_1440 = iMA(NULL, 0, 1440, 0, MODE_SMA, PRICE_CLOSE, 0);
  //}

  //移動平均線の値取得のプリントデバッグ
  Print(get_MA_5);
  Print(get_MA_14);
  Print(get_MA_21);
  Print(get_MA_60);
  Print(get_MA_240);
  Print(get_MA_1440);

  //一目均衡表の値を取得(重要なのは先行スパンA,B=雲になる)
  double get_Tenkansen = iCustom(NULL, 0, "Ichimoku", 9, 26, 52, 0, 1);
  double get_Kijunsen = iCustom(NULL, 0, "Ichimoku", 9, 26, 52, 1, 1);
  double get_SenkouSpanA = iCustom(NULL, 0, "Ichimoku", 9, 26, 52, 2, 1);
  double get_SenkouSpanB = iCustom(NULL, 0, "Ichimoku", 9, 26, 52, 3, 1);
  double get_ChikouSpan = iCustom(NULL, 0, "Ichimoku", 9, 26, 52, 4, 27);

  //一目均衡表の値取得のプリントデバッグ
  Print(get_Tenkansen);
  Print(get_Kijunsen);
  Print(get_SenkouSpanA);
  Print(get_SenkouSpanB);
  Print(get_ChikouSpan);

  //ローソク足の値取得
  double get_Candle_high = iHigh(NULL, PERIOD_M5, 0);
  double get_Candle_low = iLow(NULL, PERIOD_M5, 0);
  double get_Candle_start = iOpen(NULL, PERIOD_M5, 0);
  double get_Candle_end = iClose(NULL, PERIOD_M5, 0);

  //ローソク足の値取得のプリントデバッグ
  Print(get_Candle_high);
  Print(get_Candle_low);
  Print(get_Candle_start);
  Print(get_Candle_end);

  //前日のローソク足と当日のローソク足の情報を取得する

  //======移動平均線の傾きを求める

  //======移動平均線の傾きが上昇傾向の傾きかどうかの判断を行う

  Comment(
      "\n",
      " 5移動平均線：", MA_5, "\n", "\n",
      "14移動平均線：", MA_14, "\n", "\n",
      "21移動平均線：", MA_21, "\n", "\n",
      "60移動平均線：", MA_60, "\n", "\n",
      "240移動平均線：", MA_240, "\n", "\n",
      "1440移動平均線：", MA_1440);
  // int buy = OrderSend(Symbol(), OP_BUY, LOT, Ask, 30, Ask - STOPLOSS_WIDTH, Ask + TAKEPROFIT_WIDTH, "自動売買を作ろう！",MAGICMA, clrNONE);
  // OrderSend(Symbol(), OP_BUY, 0.01, Ask, 0, Bid + 0.1, 0, "Long",MAGICMA, 0, Red);

  //======前提条件確認：雲とローソク足の位置関係を判定し上昇トレンドか下降トレンドを判定する======
  //〜orderFlag=1上昇トレンドエントリーフラグ〜
  if (get_Candle_high > get_Candle_end && get_Candle_end > get_Candle_start && get_Candle_start > get_Candle_low && get_Candle_low > get_SenkouSpanA && get_SenkouSpanA > get_SenkouSpanB)
  {
    orderFlag = 1;
    // OrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,3,0,0,"",MAGICMA,0,Blue);
    Print("Flag :" + orderFlag);
  }
  //〜orderFlag=2下降トレンドエントリーフラグ〜
  else if (get_Candle_low < get_Candle_end && get_Candle_end < get_Candle_start && get_Candle_start < get_Candle_high && get_Candle_high < get_SenkouSpanA && get_SenkouSpanA < get_SenkouSpanB)
  {
    orderFlag = 2;
    Print("Flag :" + orderFlag);
    // OrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,3,0,0,"",MAGICMA,0,Blue);
  }

  //〜orderFlag=0何もしない〜
  else
  {
    orderFlag = 0;
    Print("Flag :" + orderFlag);
  }

  //======上記で取得した処理フラグをもとに移動平均線とローソク足の位置関係を判定する======
  //〜上昇トレンド：orderFlag=1〜
  if (orderFlag == 1)
  {
    if (get_MA_5 > get_MA_14 && get_MA_14 > get_MA_21 && get_MA_21 > get_MA_60 && get_MA_60 > get_MA_240 && get_MA_240 > get_MA_1440)
    { //ポジションが０の時の注文
      if (OrdersTotal() == 0)
      {
        Print("HELLO LONG");
        OrderSend(Symbol(), OP_BUY, LotsOptimized(), Ask, 3, 0, 0, "", MAGICMA, 0, Blue);
      }
      //ポジションが0以上ならもう一度パーフェクトオーダーかを確認する
      else if (OrdersTotal() > 0)
      {
        //上昇パーフェクトオーダー時の注文関数
      }
    }
  }

  //〜下降トレンド：orderFlag=2〜
  else if (orderFlag == 2)
  { //ポジションが０の時の注文
    if (get_MA_5 < get_MA_14 && get_MA_14 < get_MA_21 && get_MA_21 < get_MA_60 && get_MA_60 < get_MA_240 && get_MA_240 < get_MA_1440)
    {
      if (OrdersTotal() == 0)
      {
        Print("HELLO SHORT");
        OrderSend(Symbol(), OP_SELL, LotsOptimized(), Bid, 3, 0, 0, "", MAGICMA, 0, Red);
      }
      //ポジションが0以上ならもう一度パーフェクトオーダーかを確認する
      else if (OrdersTotal() > 0)
      {
        //下降パーフェクトオーダー時の注文関数
      }
    }
    else
    {
      Print("HELLO 10");
      return;
    }

    //======CrossMadante用のエントリー条件判定処理(自動売買)======
    //条件１：取得した移動平均線の値が過去のどの値よりも大きい

    //条件２：取得した移動平均線の値がパーフェクトオーダーとなっている(下落の場合：短期 < 中期　< 長期)

    // OrderSend(NULL, OP_BUY, 0.01, Ask, 0, Bid + 0.1, 0, "Long", magicNumber, 0, Red); //ロングエントリー
    //上昇の場合：短期 > 中期 > 長期
    if (MA_5 > MA_14 && MA_21 > MA_60 && MA_240 > MA_1440)
    {
      // OrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,3,0,0,"",MAGICMA,0,Blue); //ロングエントリー
      Print("HELLO LONG");
    }

    //下落の場合：短期 < 中期　< 長期
    else if (MA_5 < MA_14 && MA_21 > MA_60 && MA_240 > MA_1440)
    {
      // OrderSend(Symbol(),OP_SELL,LotsOptimized(),Bid,3,0,0,"",MAGICMA,0,Red); //ショートエントリー
      Print("HELLO SHORT");
    }

    else
    {
      return;
    }
    //条件３：5SMAと最新のローソク足の値の比較を行いエントリーを考える。

    //条件4：新しい移動平均線の値が毎回前回の移動平均線の値よりも更新できていることを確認する

    //=======決済ロジック=======
    //決済ロジック条件の前提条件に移動平均線の値が前回よりも更新しなくなったタイミングを一度判定する。(保有し続けるか一度利益確定するかを判定する)

    for (int j = 0; j < OrdersTotal(); j++)
    {
      //ポジションを選択
      if (OrderSelect(j, SELECT_BY_POS, MODE_TRADES))
      {
        //ポジションの通貨ペアとEAの通貨ペアが一致しているか
        if (OrderSymbol() == Symbol())
        {
          //マジックナンバーが一致しているか
          if (OrderMagicNumber() == MAGICMA)
          {
            //買いポジションの場合
            if (OrderType() == OP_BUY)
            {
              positionNum++;
              //ここに決済ロジックを書く（if文）
              // bool close = OrderClose(OrderTicket(), OrderLots(), OrderOpenPrice(), SLIPPAGE);
            }
            //売りポジションの場合
            if (OrderType() == OP_SELL)
            {
              positionNum++;
              //ここに決済ロジックを書く（if文）
              // bool close = OrderClose(OrderTicket(), OrderLots(), OrderOpenPrice(), SLIPPAGE);
            }
          }
        }
      }
    }
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
      //ここにポジションビの情報を１つ１つチェックするためのプログラムを書く
      Comment("\n",
              "現在のポジション: ", i);
    }
    //}
  }
}

//+------------------------------------------------------------------+