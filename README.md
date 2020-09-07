# Ubuntu/Xenial64 based box for the VCCW v3.x

[![Build Status](https://travis-ci.org/vccw-team/vccw-xenial64.svg?branch=master)](https://travis-ci.org/vccw-team/vccw-xenial64)

## What's installed

* Apache
* MySQL
* PHP 7
* Ruby 2.3
* Node.js 6.5

## How to create a box

Install vagrant-vbguest.

```
$ vagrant plugin install vagrant-vbguest
```

Provision.

```
$ vagrant box update
$ vagrant up
```

Run tests.

```
$ bundle install --path=vendor/bundle
$ bundle exec rake spec
```

Create a package.

```
$ vagrant package
```

Run with VCCW.

```
$ vagrant box add vccw-xenial64 package.box --force
```

Edit the `site.yml` in the VCCW v3 like following.

```
wp_box: vccw-xenial64
```

Then run provision.

```
$ vagrant up
```

Notes:
* Enable http2
  * install apache2 latest:
    ```
    add-apt-repository -y ppa:ondrej/apache2
    apt update
    apt –only-upgrade install apache2 -y
    a2enmod http2
    service apache2 restart
    ```
  * enable it in the `/etc/apache2/apache2.conf` file:
    ```
    Protocols h2 http/1.1
    ```
  * edit `VirtualHost` file:
    ```
    Protocols http/1.1
    <VirtualHost ...>
        ServerName test.example.org
        Protocols h2 http/1.1
    </VirtualHost>
    ```