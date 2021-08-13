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
  Q1) VALIDATE PASSWORD PLUGIN can be used to test passwords and improve security. ~~~
      Would you like to setup VALIDATE PASSWORD plugin?
      Press y|Y for Yes, any other key for No:
  A1) Y
  
  Q2) There are three levels of password validation policy:
      LOW    Length >= 8
      MEDIUM Length >= 8, numeric, mixed case, and special characters
      STRONG Length >= 8, numeric, mixed case, special characters and dictionary file
      Please enter 0 = LOW, 1 = MEDIUM and 2 = STRONG:
  A2) 1
  
  Q3) Remove anonymous users? (Press y|Y for Yes, any other key for No) :
  A3) Y
  
  Q4) Normally, root should only be allowed to connect from 'localhost'.
      This ensures that someone cannot guess at the root password from the network.
      Disallow root login remotely? (Press y|Y for Yes, any other key for No) :
  A4) Y (But, if you need remote, press N) ...
  
  Q5) By default, MySQL comes with a database named 'test' that anyone can access.
      This is also intended only for testing, and should be removed before moving into a production environment.
      Remove test database and access to it? (Press y|Y for Yes, any other key for No) :
  A5) Y
  
  Q6) Reloading the privilege tables will ensure that all changes made so far will take effect immediately.
      Reload privilege tables now? (Press y|Y for Yes, any other key for No) :
  A6) Y
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
mysql> CREATE USER '{id}'@'localhost' IDENTIFIED BY '{password}';
mysql> GRANT ALL PRIVILEGES ON *.* TO '{id}'@'localhost' WITH GRANT OPTION;
```

## Troubleshooting
### Forgot Root password
```
> USE mysql;
> ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '{password}';
```

## Related Service
  - [Apache2](./apache2.md)
  - [PHP](./php.md)
  - [phpMyAdmin]()
