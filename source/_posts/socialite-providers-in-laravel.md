---
title: Laravel 实现第三方登录认证（包括微博、QQ、微信、豆瓣）
date: 2016-03-01 15:00:38
categories:
    - php
tags:
    - php
    - laravel
---

## 前言

第三方登录认证能简化用户登录/注册的操作，降低用户登录/注册的门槛，对提高应用的用户转化率很有帮助。

## Socialite

Laravel 为我们提供了简单、易用的方式，使用 [Laravel Socialite](https://github.com/laravel/socialite) 进行 OAuth（OAuth1 和 OAuth2 都有支持） 认证。

Socialite 目前支持的认证有 Facebook、Twitter、Google、LinkedIn、GitHub、Bitbucket。
Socialite 的用法官方文档中已经讲得很详细了，恕不赘述。
Laravel 官方文档 [https://laravel.com/docs/5.1/authentication#social-authentication](https://laravel.com/docs/5.1/authentication#social-authentication)

## SocialiteProviders
[SocialiteProviders](https://github.com/SocialiteProviders) 通过扩展 Socialite 的 Driver，实现了很多第三方认证。国内的有：微博、QQ、微信、豆瓣。当然你自己也可以参照实现其他的，只要那个网站支持 OAuth。
SocialiteProviders 的使用也超级简单易用，每个都对应了文档。其实，不懂英文也能看懂。
文档地址：http://socialiteproviders.github.io/

## 以 Weibo 为例

### 1.安装

```
composer require socialiteproviders/weibo
```

### 2.添加 Service Provider
如果之前添加过 Socialite Provider，得先注释掉：
文件 `config/app.php`

```php
  'providers' => [
  //    Laravel\Socialite\SocialiteServiceProvider::class,
      SocialiteProviders\Manager\ServiceProvider::class, // add
  ],
```

### 3.添加 Facades Aliase
如果之前安装 Socialite 时添加过，就不需要再添加了。
还是文件 `config/app.php`

```php
'aliases' => [
    'Socialite' => Laravel\Socialite\Facades\Socialite::class, // add
],
```

### 4.添加事件处理器
文件 `app/Providers/EventServiceProvider.php`

```php
protected $listen = [
    'SocialiteProviders\Manager\SocialiteWasCalled' => [
        'SocialiteProviders\Weibo\WeiboExtendSocialite@handle',
    ],
];
```

这里顺便提一下 SocialiteProviders 的原理。

`SocialiteProviders\Manager\ServiceProvider` 实际上是继承于 `Laravel\Socialite\SocialiteServiceProvider` 的，这是它的源码：

```php
<?php

namespace SocialiteProviders\Manager;

use Illuminate\Contracts\Events\Dispatcher;
use Laravel\Socialite\SocialiteServiceProvider;

class ServiceProvider extends SocialiteServiceProvider
{
    /**
     * @param Dispatcher         $event
     * @param SocialiteWasCalled $socialiteWasCalled
     */
    public function boot(Dispatcher $event, SocialiteWasCalled $socialiteWasCalled)
    {
        $event->fire($socialiteWasCalled);
    }
}
```
它只是在启动时会触发 `SocialiteWasCalled` 事件，刚才在 `SocialiteProviders\Manager\SocialiteWasCalled` 事件的监听器中加上了事件处理器：`SocialiteProviders\Weibo\WeiboExtendSocialite@handle`。处理器的源码：

```php
<?php

namespace SocialiteProviders\Weibo;

use SocialiteProviders\Manager\SocialiteWasCalled;

class WeiboExtendSocialite
{
    public function handle(SocialiteWasCalled $socialiteWasCalled)
    {
        $socialiteWasCalled->extendSocialite('weibo', __NAMESPACE__.'\Provider');
    }
}
```
处理器做的事情就是为 Socialite 添加了一个 weibo Driver，这样就可以使用 weibo 的 Driver 了。

### 5.添加路由
文件 `app/Http/routes.php`

```php
// 引导用户到新浪微博的登录授权页面
Route::get('auth/weibo', 'Auth\AuthController@weibo');
// 用户授权后新浪微博回调的页面
Route::get('auth/callback', 'Auth\AuthController@callback');
```

### 6.配置
文件 `config/services.php`

```php
'weibo' => [
    'client_id' => env('WEIBO_KEY'),
    'client_secret' => env('WEIBO_SECRET'),
    'redirect' => env('WEIBO_REDIRECT_URI'),
],
```

文件 `.env`

```php
WEIBO_KEY=yourkeyfortheservice
WEIBO_SECRET=yoursecretfortheservice
WEIBO_REDIRECT_URI=http://localhost/public/auth/callback
```

当然，直接将配置的具体参数写在 `config/services.php` 中也是可以的，但是不推荐这样。因为 `config/services.php` 属于代码文件，而 `.env` 属于配置文件。当代码上线是只要应用线上环境的配置文件即可，而不需要改动代码文件，这算是一个最佳实践吧。
至于 `WEIBO_KEY` 和 `WEIBO_SECRET` 的具体值，这个是由新浪微博分发给你的，在新浪微博的授权回调页中填写 `WEIBO_REDIRECT_URI`。这些细节已经超出本文的内容，建议直接到 http://open.weibo.com 查阅新浪微博的手册。


### 7.代码实现
文件 `app/Http/Controllers/Auth/AuthController.php`

```php
public function weibo() {
    return \Socialite::with('weibo')->redirect();
    // return \Socialite::with('weibo')->scopes(array('email'))->redirect();
}

public function callback() {
    $oauthUser = \Socialite::with('weibo')->user();

    var_dump($oauthUser->getId());
    var_dump($oauthUser->getNickname());
    var_dump($oauthUser->getName());
    var_dump($oauthUser->getEmail());
    var_dump($oauthUser->getAvatar());
}
```

访问 `http://localhost/public/auth/weibo`，会跳转到新浪微博的登录授权页面，授权成功后，会跳转到 `http://localhost/public/auth/callback`
返回的结果：

```php
string(10) "3221174302"
string(11) "Mr_Jing1992"
NULL
NULL
string(50) "http://tp3.sinaimg.cn/3221174302/180/40064692810/1"
```

user 对象是现实了接口 `Laravel\Socialite\Contracts\User` 的，有以下几个方法：

```php
<?php

namespace Laravel\Socialite\Contracts;

interface User
{
    public function getId();
    public function getNickname();
    public function getName();
    public function getEmail();
    public function getAvatar();
}
```

当然，并不是有了这些方法就一定能获取到你需要的数据的。比如，在新浪的接口中，想要获取用户的 email 是得用户授权的，得到授权后请求获取邮箱的接口，才能拿到用户的邮箱。
详情参见：
[http://open.weibo.com/wiki/Scope](http://open.weibo.com/wiki/Scope)

[http://open.weibo.com/wiki/2/account/profile/email](http://open.weibo.com/wiki/2/account/profile/email)

但是，`id` 这个应该是所有第三方认证服务提供商都会返回的。不然那就没有办法作账号关联了。

获取到第三方的 `id` 后，如果这个 `id` 和你网站用户账号有绑定，就直接登录你网站用户的账号。如果没有任何账号与之绑定，就应该提示用户绑定已有账号或者是注册新账号什么的，这些具体逻辑就不在多说了。还有，在新浪上面还有一个取消授权回调页的值需要填，是用户在授权页点击“取消”按钮时新浪回调的页面。这个可以设置为你网站的登录页面或者其他页面。
