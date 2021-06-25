# Apache2
### Environment
- OS : Linux 18.04.5 LTS

## Install
```
$ su -
$ apt-get update
$ apt-get upgrade
$ apt-get install apache2
```

## Setting
- /etc/apache2/apache2.conf
```
HostnameLookups Off

LogLevel warn

#<Directory /var/www/>
#    Options Indexes FollowSymLinks
#    AllowOverride None
#    Require all granted
#</Directory>

AccessFileName .htaccess
```

## Default conf file
- {Apache2 dir}/sites-avaliable/default.conf [default.conf](./samples/apache2/default.conf)
- {Apache2 dir}/sites-avaliable/default-ssl.conf [default-ssl.conf](./samples/apache2/default-ssl.conf)

## Related Service
  - [PHP](./PHP.md)
  - [MySQL](./MySQL.md)
