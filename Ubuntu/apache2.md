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

## Related Service
- SQL
  - [MySQL](./MySQL.md)
