# Measuring

Growth Hack 脫離不了「數據分析」和「量化指標」。

作介面優化與行為分析時，我們常用「漏斗」(Funnel) 這個概念去形容不同時期轉換的留存率和流失率。

## Funnel

### Google Analytics

傳統大家比較熟知的分析工具，非屬 Google Analytics。Google Analytics 提供了以下幾個常見指標：

* 頁面瀏覽量（Page View）：網站在某一段時間內的頁面瀏覽量是多少。
* 用戶瀏覽量（User View）：網站在某一段時間內的用戶瀏覽量是多少。
* 渠道來源（traffic sources）：用戶流量來源於哪些不同的渠道。
* 訪客特徵（User demographics）：訪問用戶具有哪些特徵值，用來做用戶分類。
* 訪問路徑（Flow Report）：用戶在網站上的訪問行為，各個頁面的進入率和跳出率。

不過，整個 Google Analytics 的想法是以 Visit 作為中心的。

### Mixpanel

實際上作 Growth Hack 與 UX，則多半以用戶行為為中心去改變策略。

通常的會採用 [Mixpanl](http://mixpanel.com) 這套工具去量測行為，用 [Optimizely](http://optimizely.com) 進行 A/B Testing。

Mixpanel 主要提供了幾大關鍵指標：

* 用戶動態分析（Trends）：你關心的用戶行為發生了多少次，佔總比例多少。
* 行為漏斗模型（Funnels）：某些關鍵行為是怎麼發生了，每一步有多少的留存率和流失率。
* 用戶活躍度（Cohorts）：網站用戶的活躍度如何，可以用來區分忠實用戶和普通用戶。
* 單用戶行為分析（People）：單一用戶在網站上做了哪些操作，過程是如何的。

透過在網站的介面中埋 Event 讓使用者觸發，去描繪出使用者的操作行為，並進而觀測轉換的留存率和流失率。
