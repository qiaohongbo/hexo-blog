---
title: 如何简单的输出 “N 分钟前”、“1 天前” 等友好的 time ago 时间
date: 2016-02-29
categories:
    - php
tags:
    - php
    - laravel
    - carbon
---

我们会经常有这样的需求，要求将发布时间显示为 “N 分钟前”、“1 天前” 等 time ago 的格式。

在 Laravel 中这相当简单，不需要依赖其它库（框架内已经依赖的就够了）即可完成。

### 第一步，在 app/Providers/AppServiceProvider.php 中设置地区：

```php
    public function boot()
    {
        \Carbon\Carbon::setLocale('zh');
    }
```

### 第二步，模板中使用 Carbon 的 diffForHumans 方法来输出友好时间

```
    {{ $comment->created_at->diffForHumans() }} // 3小时前
```

参考：[http://carbon.nesbot.com/docs/#api-localization](http://carbon.nesbot.com/docs/#api-localization)