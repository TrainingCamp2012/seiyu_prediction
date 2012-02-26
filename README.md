# What's?  
Wikipediaを用いた声優リストの一覧取得や共演関係予測を行う．
# Usage   
`ruby link_prediction.rb ../data/seiyu_women_co_graph_node_pair.txt 声優名 深さ`
`ruby link_prediction.rb ../data/seiyu_women_co_graph_node_pair.txt 野水伊織 3`
# About method
[リンク予測](http://d.hatena.ne.jp/repose/20120118/1326814365)  
# Bugs
声優名が適切に取得できなかったデータからグラフを作っているので共演関係グラフに存在しない声優がいる  
アニメリストが不適切  
男性声優が考慮されていない
