# Optimizely

![](http://d.pr/i/138Ee+)

## 安裝 Optimizely

開啟帳號後，到 Settings 裡，取得專屬 JavaScript

![](http://d.pr/i/1arfO+)

埋到網站 Template 裡面

![](http://d.pr/i/12jDS+)


這裡有點小技巧。Segment IO 要放在 Optimizely 前面，不然會有 Bug。

![](http://d.pr/i/1jZqM+)

Optimizely 要作 A/B Testing，要先對不同 Visitor 分群。所以要找一個地方埋 Identify Event。

![](http://d.pr/i/LWRj+)


（然後記得把網站 deploy 到 Production 上，因為 Optimizely 是透過類似像 Google Chrome Inspector 的方式抓 DOM 並且修改 ）

打開 Segment.io 的整合 選項

![](http://d.pr/i/10ftl+)


## 建立實驗


![](http://d.pr/i/12SfX+)

假設我們想把「 66K 工作網」改成 「66K 高薪工作網」

![](http://d.pr/i/1bFkE+)

存檔後，就會建立一個 Variant

![](http://d.pr/i/7Ge9+)

到 Traffic Allocation 可以設定分配多少比例

 ![](http://d.pr/i/1kYv4+) 

預設是 50% , 50 %

![](http://d.pr/i/B4vV+)

都設定好後按 Start Experiment

![](http://d.pr/i/1fvRJ+)

應該就可以在網站上看到結果了。

（我都會設 Variant #1 為 99% 去確保真的生效）

![](http://d.pr/i/13ExD+)