# PHP
### Environment
- OS : Linux 18.04.5 LTS
- PHP : 

## Install
```
$ su -
$ apt-get update
$ apt-get upgrade

** Using MySQL **
$ apt-get install php php-cli php-fpm php-json php-common php-mysql php-zip php-gd php-mbstring php-curl php-xml php-pear php-bcmath

** Only PHP **
$ apt-get install php php-cli php-fpm php-json php-common php-zip php-gd php-mbstring php-curl php-xml php-pear php-bcmath
```

## Setting
- /etc/php/{version}/apache2/php.ini
```
engine = On
short_open_tag = On
max_execution_time = 30
max_input_time = 60
memory_limit = 256M
error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT
display_error = Off
display_startup_errors = Off
log_errors = On
report_memleaks = On
html_errors = On
post_max_size = 32M (or above)
file_uploads = On
upload_max_filesize = 8M (or above)
max_file_uploads = 16 (or above)
```

## Related Service
  - [Apache2](./apache2.md)
  - [MySQL](./MySQL.md)
