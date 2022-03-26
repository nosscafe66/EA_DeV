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

//サフィックスの設定
string suffix;

//連続でエントリーしないためのフラグ
datetime time = Time[0];

//外部入力(変更可能性あり)
input double LOT = 0.01;             //ロット数の設定
input double MAXLOT = 1;             //最大ロット数の設定
input double MAXPOSITION = 200;      //最大ポジション数
input double TAKEPROFIT_WIDTH = 100; //利確幅（単位point）
input double STOPLOSS_WIDTH = 100;   //損切り幅（単位point）

//マジックナンバーの設定(変更可能性あり)
int magicNumber = 10;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
  //---
  // if(StringLen(Symbol()) > 6) suffix = StringSubstr(Symbol(),6);
  // else suffix = "";

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

#property script_show_confirm 1
//初期関数(価格が動くごとに実行)
void OnTick()
{
  //--
  //現在のポジション数を代入する変数
  int positionNum = 0;

  //ここに現在のポジション数を更新するプログラムを書く

  //最大ロット数のチェック
  if (LOT > MAXLOT)
    Print(MAXLOT);
  return;

  //最大ポジション数のチェック
  if (positionNum > MAXPOSITION)
    Print(MAXPOSITION);
  return;

  //連続でエントリーしないようにする処理
  // time変数が、現在の時間ではない場合に実行する
  if (time != Time[0])
  {

    // time変数に、現在の時間を代入
    time = Time[0];

    //↓↓↓↓↓↓↓↓↓↓↓↓ここから下にロジックやエントリー注文を書く↓↓↓↓↓↓↓↓↓↓↓↓
    //=======Cross_Madante用のエントリーロジック======

    //エントリーサンプル（実行しないでください！！）
    // int buy = OrderSend(Symbol(), OP_BUY, LOT, Ask, 30, Ask-STOPLOSS_WIDTH, Ask+TAKEPROFIT_WIDTH, "自動売買を作ろう！", 9999, clrNONE);

    //=====移動平均線の値を取得する処理======

    //移動平均線の値取得変数宣言
    double MA_5;
    double MA_14;
    double MA_21;
    double MA_60;
    double MA_240;
    double MA_1440;

    //移動平均線の値を取得
    MA_5 = iMA(NULL, 0, 5, 0, MODE_SMA, PRICE_CLOSE, 0);
    MA_14 = iMA(NULL, 0, 14, 0, MODE_SMA, PRICE_CLOSE, 0);
    MA_21 = iMA(NULL, 0, 21, 0, MODE_SMA, PRICE_CLOSE, 0);
    MA_60 = iMA(NULL, 0, 60, 0, MODE_SMA, PRICE_CLOSE, 0);
    MA_240 = iMA(NULL, 0, 240, 0, MODE_SMA, PRICE_CLOSE, 0);
    MA_1440 = iMA(NULL, 0, 1440, 0, MODE_SMA, PRICE_CLOSE, 0);

    //移動平均線の値取得のプリントデバッグ
    Print(MA_5);
    Print(MA_14);
    Print(MA_21);
    Print(MA_60);
    Print(MA_240);
    Print(MA_1440);

    Comment("\n",
            " 5移動平均線：", MA_5, "\n", "\n",
            "14移動平均線：", MA_14, "\n", "\n",
            "21移動平均線：", MA_21, "\n", "\n",
            "60移動平均線：", MA_60, "\n", "\n",
            "240移動平均線：", MA_240, "\n", "\n",
            "1440移動平均線：", MA_1440);

    //条件１：取得した移動平均線の値が過去のどの値よりも大きい
    //条件２：取得した移動平均線の値がパーフェクトオーダーとなっている
    //条件３：

    //=======決済ロジック=======
    for (int i = 0; i < OrdersTotal(); i++)
    {
      //ポジションを選択
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
        //ポジションの通貨ペアとEAの通貨ペアが一致しているか
        if (OrderSymbol() == Symbol())
        {
          //マジックナンバーが一致しているか
          if (OrderMagicNumber() == magicNumber)
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
  }
}

//+------------------------------------------------------------------+