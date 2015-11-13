## 整合 Optimizely 與 Mixpanel

到 Segement IO 的 Debugger。因為埋了 "identify" event。所以現在會看到也抓到了 Session ID

![](http://d.pr/i/FJNZ+)

點開，切到 Raw 分頁就會看到 Variant #1 的標記

![](http://d.pr/i/1fMbK+)

此時再到 Mixpanel 打開當初所設的 Funnel

![](http://d.pr/i/1g2xv+)

就可以把 Variant #1 的變數抓出來了

![](http://d.pr/i/rSoc+)

這樣一來就可以用這樣的技巧實作 A/B Testing。測試哪樣的 Copy 或哪樣的底圖可以增進點擊率或下一步的行為。

