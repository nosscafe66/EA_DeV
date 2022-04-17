# 開発で調査したこと

・EA開発の指南書
https://yukifx.web.fc2.com/sub/reference/02_stdconstans/object/object_z_OBJ_RECTANGLE_LABEL.html

・https://fxantenna.com/how-to-make-ea-practice/

関数一覧
https://zyunafx.com/mql4_reference/

・イベント関数について
https://yukifx.web.fc2.com/sub/reference/01_basic/function/function_event.html

・コンパイルエラーについて
https://yukifx.web.fc2.com/sub/qa/qa_error/cone/qa_error_root.html

・インジケーター改造
https://mtplace.biz/547.html

・MQL4逆引き
https://blog.codinal-systems.com/mql4technique/


・ピラミッティング判定処理
https://www.youtube.com/watch?v=X7-M_7snyM4

https://autofx-now.com/myea/pyramid-cf-html

iMa関数
https://creator.fx-ea-system-project.com/mt4-indicator/ima/

・配列について
https://mql-programing.com/array/


新規注文時間制限
https://get-daze.net/2018/10/14/time-rimit/

Ordersend関数について
https://buco-bianco.com/mql4-ordersend-function/


・パーフェクトオーダー
https://creator.fx-ea-system-project.com/mt4-indicator/perfect-order/
https://fx.ichizo.biz/2017/02/09/perfectorder.html

・一目均衡表
https://mt4trader.net/ichimoku-candle-ea.html
https://fx-prog.com/ea-sorce10/
https://mt4-traders.com/reference/iichimoku/

・通貨ペアの名称取得
https://www.oanda.jp/lab-education/fx_on/%E4%B8%8A%E7%B4%9A%E8%80%85/2931/
https://yukifx.web.fc2.com/sub/make/01_root/time_series/time_series_othersymbol.html

・全通貨監視
https://mt4-mt5-indicators.com/binary_alert/


通貨ペアの取得：_Symbol
最小値幅の取得：_Point
小数点以下の桁数：_Digit
現在のチャートのタイムフレームが格納されている変数：_Period

30分足の場合「30」、1時間足の場合「60」、日足の場合「1440(=60×24)」という数値が入っています。

MQL4のデータ型

int 整数型
double 実数型
string 文字列型

新規注文関数：OrderSend()

Print("証拠金通貨：",AccountInfoString(ACCOUNT_CURRENCY));
Print("レバレッジ：",AccountInfoInteger(ACCOUNT_LEVERAGE));
Print("残高：",AccountInfoDouble(ACCOUNT_BALANCE));
Print("有効証拠金：",AccountInfoDouble(ACCOUNT_EQUITY));
Print("必要証拠金：",AccountInfoDouble(ACCOUNT_MARGIN));
Print("余剰証拠金：",AccountInfoDouble(ACCOUNT_MARGIN_FREE));
Print("証拠金維持率：",AccountInfoDouble(ACCOUNT_MARGIN_LEVEL));

ポジションの選択：OrderSelect(チケット番号,SELECT_BY_TICKET)

doubleOrderLots();//注文のロット数
doubleOrderOpenPrice();//約定した価格
doubleOrderClosePrice();//現在の決済価格
doubleOrderProfit();//損益

OrderClose(ticket,OrderLots(),OrderClosePrice(),3);

OnInit()
OneDeinit()
OnTick()
OnCalculate()


相場の上昇トレンドを示唆する動き、雲抜け、EMA5をしたから上に抜いたとき

一本前のバーを確認する。
doublemom1=iMomentum(_Symbol,0,MomPeriod,PRICE_CLOSE,1);



Metaeditor使用方法など
https://enjoy-fx.net/how-to-make-expert-advisor/


pythonとmql4の連携
https://lawn-tech.jp/mql4python.html


トレードデータとデータベース連携
https://duckduckgo.com/?q=Mql4+%E3%83%87%E3%83%BC%E3%82%BF%E3%83%99%E3%83%BC%E3%82%B9&ia=web


Mysqlでデータ登録
http://yanoshin.jp/entry_181.html


データ登録
https://qiita.com/YasunoriKM/items/a92059cb3d7bae385f38


インジケータからLINE通知
https://www.dr-ea.com/meta-blog/metatrader4/free-tool-mt4/mt4-indicator-to-line.html

LINE連携
https://www.dr-ea.com/meta-blog/metatrader4/free-tool-mt4/mt4-to-line.html

LINE連携
https://www.dr-ea.com/meta-blog/metatrader4/auto-trade/system-trade.html


インジケータの値をCSV化する方法
https://zyunafx.com/mql4_script/

次のローソク足の残り時間を計算する方法
https://blog.codinal-systems.com/timer/


トレードシステム開発ブログ
https://blog.codinal-systems.com/mql4technique/

vscode mql4
https://fx-ai-trading.com/fx/mql/vs-code.html


新しいローソク足が出現した時にだけ判断する。
https://fx7se.com/mql/mql_ashione