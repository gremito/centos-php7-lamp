# centos-php7-lamp
This is docker image for LAMP.
* CentOS 6.9
* MySQL 5.6.38
* PHP 7.1.11
* Apache 2.2.15

## Build

```
$ cd centos-php7-lamp
$ sudo docker build -t gremito/lamp .
```

## Run

```
$ sudo docker run -d -p 80:80 gremito/lamp
```

## exec

```
$ sudo docker exec -it コンテナ名 /bin/bash
```


