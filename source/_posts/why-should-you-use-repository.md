---
title: 为什么你应该使用 Repository
date: 2016-02-29
categories:
    - php
tags:
    - php
    - laravel
---


### Repository 模式

为了保持代码的整洁性和可读性，使用 `Repository Pattern` 是非常有用的。事实上，我们也不必仅仅为了使用这个特别的设计模式去使用 `Laravel`，然而在下面的场景下，我们将使用 `OOP` 的框架 `Laravel` 去展示如何使用 `repositories` 使我们的 `Controller` 层不再那么啰嗦、更加解耦和易读。下面让我们更深入的研究一下。

### 不使用 `repositories`

其实使用 `Repositories` 并不是必要的，在你的应用中你完全可以不使用这个设计模式的前提下完成绝大多数的事情，然而随着时间的推移你可能把自己陷入一个死角，比如不选择使用 `Repositories` 会使你的应用测试很不容易，具体的实现将会变的很复杂，下面我们看一个例子。 `HousesController.php`

```php
<?php
class HousesController extends BaseController {
    public function index()
    {
        $houses = House::all();
        return View::make('houses.index',compact('houses'));
    }

    public function create()
    {
        return View::make('houses.create');
    }
    public function show($id)
    {
        $house = House::find($id);
        return View::make('houses.show',compact('house'));
    }
}
```

这是一个很典型的一段代码使用 `Eloquent` 和数据库交互，这段代码工作的很正常，但是 `controller` 层对于 `Eloquent` 而言将是紧耦合的。在此我们可以注入一个 `repository` 创建一个解耦类型的代码版本，这个解耦的版本代码可以使后续程序的具体实现更加简单。

### 使用 `repositories`

其实完成整个 `repository` 模式需要相当多的步骤，但是一旦你完成几次就会自然而然变成了一种习惯了，下面我们将详细介绍每一步。

1: 创建 `Repository` 文件夹

首先我们需要在 `app` 文件夹创建自己 `Repository` 文件夹 `repositories`，然后文件夹的每一个文件都要设置相应的命名空间。

2: 创建相应的 `Interface` 类

第二步创建对应的接口，其决定着我们的 `repository` 类必须要实现的相关方法，如下例所示，在此再次强调的是命名空间一定要记得加上。  `HouseRepositoryInterface.php`

```php
<?php namespace App\Repositories;

interface HouseRepositoryInterface {
    public function selectAll();

    public function find($id);
}
```

3: 创建对应的 `Repository` 类

现在我们可以创建我们 `repository` 类 来给我们干活了，在这个类文件中我们可以把我们的绝大多数的数据库查询都放进去，不论多么复杂。如下面的例子 `DbHouseRepository.php`

```php
<?php namespace App\Repositories;

use House;

class DbHouseRepository implements HouseRepositoryInterface {

    public function selectAll()
    {
        return House::all();
    }

    public function find($id)
    {
        return House::find($id);
    }
}
```

4: 创建后端服务提供

首先你需要理解所谓服务提供，请参考手册[服务提供者](https://laravel.com/docs/5.0/providers/) `BackendServiceProvider.php`

```php
<?php namespace App\Repositories;

use Illuminate\Support\SeriveProvider;

class BackSerivePrivider extends ServiceProvider {

    public function register()
    {
        $this->app->bind('App\Repositories\HouseRepositoryInterface', 'App\Repositories\DbHouseRepository');
    }
}

```
当然你也可以新建一个文件夹主要放我们的 `provider` 相关文件。 上面一段代码主要说的是，当你在 `controller` 层使用类型提示 `HouseRepositoryInterface`, 我们知道你将会使用 `DbHouseRepository`.

5: 更新你的 `Providers Array`

其实在上面的代码中，我们已经实现了一个依赖注入，但如果我们要使用在此我们是需要手动去写的，为了更为方面，我们需要增加这个 `providers` 到 `app/config/app.php` 中的 `providers` 数组里面, 只需要在最后加上 `App\Repositories\BackendServiceProvider::class`,

6: 最后使用依赖注入更新你的 `controller`

当我们完成上面的那些内容之后，我们在 `Controller` 只需要简单的调用方法代替之前的复杂的数据库调用，如下面内容： `HousesController.php`

```php
<?php

use App\repositories\HouseRepositoryInterface;

class HousesController extends BaseController {

    public function __construct(HouseRepositoryInterface $house)
    {
        $this->house = $house;
    }


    public function index()
    {
        $houses = $this->house->selectAll();

        return View::make('houses.index', compact('houses'));

    }


    public function create()
    {
        return View::make('houses.create');
    }


    public function show($id)
    {
        $house = $this->house->find($id);

        return View::make('houses.show', compact('house'));

    }
}
```

这样整个的流程就完成了。
