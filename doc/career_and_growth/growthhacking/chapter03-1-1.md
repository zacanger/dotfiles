## 在想追蹤的頁面裡面埋 Event

比如說我想要追蹤首頁的曝光，首頁的 template 檔案是在 `app/views/jobs/index.html.erb`。我會在該頁最下面埋下這樣的追蹤碼。

![](http://d.pr/i/1iaJb+)

打開 Debugger 確認有收到 Event。

![](http://d.pr/i/14blI+)

## 在想要追蹤的按鈕上埋 Event

比如說我想要追蹤首頁按鈕的點擊，我會先在按鈕上綁一個獨特的 DOM ID。

![](http://d.pr/i/1aOeh+)

然後寫 JavaScript 監聽事件

![](http://d.pr/i/T0fN+)