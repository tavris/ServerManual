# MySQL
### Environment
- ![Generic badge](https://img.shields.io/badge/UbuntU-18.04_or_Above-green.svg)

## Install
```
$ su -
$ apt-get update
$ apt-get upgrade
$ apt-get install mysql-server
```

## Setting
- Base Config
```
$ mysql_secure_installation
```

## Adjusting user authentication and privileges
```
$ mysql
mysql> SELECT user,authentication_string,plugin,host FROM mysql.user;
+------------------+-------------------------------------------+-----------------------+------------------------+
| user             | authentication_string                     | plugin                | host                   |
+------------------+-------------------------------------------+-----------------------+------------------------+
| root             |             { PASSWORD STRING }           | auth_socket           | localhost              |
| mysql.session    |             { PASSWORD STRING }           | mysql_native_password | localhost              |
| mysql.sys        |             { PASSWORD STRING }           | mysql_native_password | localhost              |
| debian-sys-maint |             { PASSWORD STRING }           | mysql_native_password | localhost              |
+------------------+-------------------------------------------+-----------------------+------------------------+
4 rows in set (0.00 sec)
```

If the root user does in fact authenticate using the `auth_socket` plugin, to configure the root account to authenticate with a password, run the following ALTER USER command. Be sure to change password to a strong password of your choosing, and note that this command will change the root password.

```
mysql> ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';
mysql> FLUSH PRIVILEGES;
mysql> SELECT user,authentication_string,plugin,host FROM mysql.user;
+------------------+-------------------------------------------+-----------------------+------------------------+
| user             | authentication_string                     | plugin                | host                   |
+------------------+-------------------------------------------+-----------------------+------------------------+
| root             |             { PASSWORD STRING }           | mysql_native_password | localhost              |
| mysql.session    |             { PASSWORD STRING }           | mysql_native_password | localhost              |
| mysql.sys        |             { PASSWORD STRING }           | mysql_native_password | localhost              |
| debian-sys-maint |             { PASSWORD STRING }           | mysql_native_password | localhost              |
+------------------+-------------------------------------------+-----------------------+------------------------+
4 rows in set (0.00 sec)
```

## Create new user
```
$ mysql -u root -p
mysql> CREATE USER '{id}'@'localhost' IDENTIFIED BY 'password';
mysql> GRANT ALL PRIVILEGES ON *.* TO '{id}'@'localhost' WITH GRANT OPTION;
```

## Related Service
  - [Apache2](./apache2.md)
  - [PHP](./php.md)
  - [phpMyAdmin]()
