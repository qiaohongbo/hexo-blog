---
title: Laravel Valet（Mac开发环境）
date: 2016-05-10 20:28:06
categories:
  - php
tags:
  - laravel
  - php

---

## 1、概述
Valet 是为 Mac 提供的极简主义开发环境，没有 Vagrant、Apache、Nginx，也没有 `/etc/hosts` 文件，甚至可以使用本地隧道公开共享你的站点。

在 Mac 中，当你启动机器时，Laravel Valet 总是在后台运行 PHP 内置的 Web 服务器，然后通过使用 DnsMasq，Valet 将所有请求代理到 `*.dev` 域名并指向本地机器安装的站点。这样一个极速的 Laravel 开发环境只需要占用7M内存。

Valet 并不是想要替代 Vagrant 或者 Homestead，只是提供了另外一种选择，更加灵活、极速、以及占用更小的内存空间。

Valet 为我们提供了以下软件和工具：

- Laravel
- Lumen
- Statamic
- Craft
- WordPress
- Jigsaw
- 静态HTML

当然，你还可以通过自定义的驱动扩展 Valet。

### Valet Or Homestead

正如你所知道的，Laravel 还提供了另外一个开发环境 Homestead。Homestead 和 Valet 的不同之处在于两者的目标受众和本地开发方式。Homestead 提供了一个完整的包含自动化 Nginx 配置的 Ubuntu 虚拟机，如果你需要一个完整的虚拟化 Linux 开发环境或者使用的是 Windows/Linux 操作系统，那么 Homestead 无疑是最佳选择。

Valet 只支持 Mac，并且要求本地安装了 PHP 和数据库服务器，这可以通过使用 Homebrew 命令轻松实现（`brew install php70` 以及 `brew install mariadb`），Valet 通过最小的资源消耗提供了一个极速的本地开发环境，如果你只需要 PHP/MySQL 并且不需要完整的虚拟化开发环境，那么 Valet 将是最好的选择。

最后，Valet 和Homestead 都是配置本地 Laravel 开发环境的好帮手，选择使用哪一个取决于你个人的喜好或团队的需求。

## 2、安装
Valet 要求 Mac 操作系统和 Homebrew。安装之前，需要确保没有其他程序如 Apache 或 Nginx 绑定到本地的 80 端口。安装步骤如下：

- 使用 `brew update`安装或更新Homebrew到最新版本
- 通过运行 `brew services list` 确保 `brew services` 有效并且能获取到正确的输出，如果无效，则需要添加。
- 通过 Homebrew 安装PHP 7.0： `brew install php70`。
- 通过 Composer 安装 Valet： `composer global require laravel/valet`（确保 `~/.composer/vendor/bin` 在系统路径中）
- 运行 `valet install` 命令，这将会配置并安装 Valet 和 DnsMasq，然后注册 Valet 后台随机启动。
- 安装完 Valet 后，尝试使用命令如 `ping foobar.dev` 在终端ping一下任意 `*.dev` 域名，如果 Valet 安装正确就会看到来自 `127.0.0.1` 的响应：

```
PING foobar.dev (127.0.0.1): 56 data bytes
64 bytes from 127.0.0.1: icmp_seq=0 ttl=64 time=0.069 ms
64 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.077 ms
64 bytes from 127.0.0.1: icmp_seq=2 ttl=64 time=0.072 ms
64 bytes from 127.0.0.1: icmp_seq=3 ttl=64 time=0.082 ms
```

每次系统启动的时候 Valet 后台会自动启动，而不需要再次手动运行 `valet start` 或 `valet install`。

#### 数据库

如果你需要数据库，可以在命令行通过 `brew install mariadb` 安装 MariaDB ，安装完成后就可以在本机通过用户名 `root` 和一个空密码连接到数据库。

## 3、服务站点
Valet 安装完成后，就可以启动服务站点，Valet 为此提供了两个命令：`park` 和 `link`

### park 命令

- 在 Mac 中创建一个新目录，例如 `mkdir ~/Sites`，然后进入这个目录并运行 `valet park`。这个命令会将当前所在目录作为web根目录。
- 接下来，在新建的目录中创建一个新的 Laravel 站点： `laravel new blog`。
- 在浏览器中访问 `http://blog.dev`。

页面截图如下：
![使用Valet搭建Laravel开发环境](http://7xq9wg.com1.z0.glb.clouddn.com/16-5-11/38857834.jpg)

这就是我们要做的全部工作。现在，所有在 `Sites` 目录中创建的 Laravel 项目都可以通过 `http://folder-name.dev` 这种方式在浏览器中访问，是不是很方便？

### link 命令

`link` 命令也可以用于本地 Laravel 站点，这个命令在你想要在目录中提供单个站点时很有用。

- 要使用这个命令，先切换到你的某个项目并运行 `valet link app-name`，这样Valet会在 `~/.valet/Sites` 中创建一个符号链接指向当前工作目录。
- 运行完 `link` 命令后，可以在浏览器中通过 `http://app-name.dev` 访问。

要查看所有的链接目录，可以运行 `valet links` 命令。你也可以通过 `valet unlink app-name` 来删除符号链接。

## 4、分享站点
Valet 还提供了一个命令用于将本地站点共享给其他人，这不需要任何额外工具即可实现。

要共享站点，切换到站点所在目录并运行 `valet share`，这会生成一个可以公开访问的 URL 并插入剪贴板，以便你直接复制到浏览器地址栏，就是这么简单。

要停止共享站点，使用 `Control + C` 即可。

## 5、查看日志
如果你想要在终端显示所有站点的日志，可以运行 `valet logs` 命令，这会在终端显示新的日志。

## 6、自定义Valet驱动
你还可以编写自定义的 Valet 驱动为运行于非 Valet 原生支持的 PHP 应用提供服务。安装完 Valet 时会创建一个 `~/.valet/Drivers` 目录，该目录中有一个 `SampleValetDriver.php` 文件，这个文件中有一个演示如何编写自定义驱动的示例。编写一个驱动只需要实现三个方法：`serves`、`isStaticFile` 和 `frontControllerPath`。

这三个方法接收 `$sitePath`、`$siteName` 和 `$uri` 值作为参数，其中 `$sitePath` 表示站点目录，如 `/Users/Lisa/Sites/my-project`，`$siteName` 表示主域名部分，如 `my-project`，而 `$uri` 则是输入的请求地址，如`/foo/bar`。

编写好自定义的 Valet 驱动后，将其放到 `~/.valet/Drivers` 目录并遵循 `FrameworkValetDriver.php` 这种命名方式，举个例子，如果你是在为 Wordpress 编写自定义的 valet 驱动，对应的文件名称为 `WordPressValetDriver.php`。

下面我们来具体讨论并演示自定义 Valet 驱动需要实现的三个方法。

### serves 方法

如果自定义驱动需要继续处理输入请求，`serves` 方法会返回 `true`，否则该方法返回 `false`。因此，在这个方法中应该判断给定的 `$sitePath` 是否包含你服务类型的项目。

例如，假设我们编写的是 `WordPressValetDriver`，那么对应 `serves`方法如下：

```php
/**
 * Determine if the driver serves the request.
 *
 * @param  string  $sitePath
 * @param  string  $siteName
 * @param  string  $uri
 * @return void
 * @translator laravelacademy.org
 */
public function serves($sitePath, $siteName, $uri)
{
    return is_dir($sitePath.'/wp-admin');
}
```

## isStaticFile 方法

`isStaticFile` 方法会判断输入请求是否是静态文件，例如图片或样式文件，如果文件是静态的，该方法会返回磁盘上的完整路径，如果输入请求不是请求静态文件，则返回 `false`：

```php
/**
 * Determine if the incoming request is for a static file.
 *
 * @param  string  $sitePath
 * @param  string  $siteName
 * @param  string  $uri
 * @return string|false
 */
public function isStaticFile($sitePath, $siteName, $uri)
{
    if (file_exists($staticFilePath = $sitePath.'/public/'.$uri)) {
        return $staticFilePath;
    }

    return false;
}
```

注： `isStaticFile` 方法只有在 `serves` 方法返回 `true` 并且请求 URI 不是 / 的时候才会被调用。

## frontControllerPath 方法

`frontControllerPath` 方法会返回前端控制器的完整路径，通常是 `index.php`：
```php
/**
 * Get the fully resolved path to the application's front controller.
 *
 * @param  string  $sitePath
 * @param  string  $siteName
 * @param  string  $uri
 * @return string
 */
public function frontControllerPath($sitePath, $siteName, $uri)
{
    return $sitePath.'/public/index.php';
}
```

## 7、其他Valet命令

| 命令 | 描述 |
| ---- | ---- |
| `valet forget` | 从”parked”目录运行该命令以便从parked目录列表中移除该目录 |
| `valet paths` | 查看你的”parked”路径 |
| `valet restart` | 重启Valet |
| `valet start` | 启动Valet |
| `valet stop` | 关闭Valet |
| `valet uninstall` | 卸载Valet |