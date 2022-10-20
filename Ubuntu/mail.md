# Postfix & Dovecot mail server
## Environment
- OS : Linux (Ubuntu 18.04.5 LTS, 22.04.1 LTS)

## Port List
  - SMTP : TCP 25, 465(SSL) or 587(SSL)
  - POP3 : TCP 110, 995(SSL)
  - IMAP : TCP 143, 993(SSL)

## DNS Setting
### Record Setting
- **A Record**
  - A NAME : mail.{domain}, VALUE : {Server IP}
  - Test<br>
    ```
    $ nslookup mail.{domain}
      Server : {Server IP}
      Address: {Server IP}#{TagNum}
      
      Non-authoritative answer:
      Name : mail.{domain}
      Address: {Server IP}
    ```
- **MX Record**
  - MX NAME : @, VALUE : mail.{domain}, Priority : {Number of Priority}
  - Test<br>
    ```
    $ nslookup -type=mx {domain}
    Server : {Server IP}
    Address: {Server IP}#{TagNum}
    
    Non-authoritative answer:
    {domain}  mail exchanger = {Number of Priority} mail.{domain}
- **SPF Record**
  - Record Type : TXT, NAME : @, VALUE : v=spf1 ip4:{Server IP} -all
  - Test<br>
    ```
    $ nslookup -type=txt {domain}
    Server : {Server IP}
    Address: {Server IP}#{TagNum}
    
    Non-authoritative answer:
    {domain}  text = v=spf1 ip4:{Server IP} -all
    ```

## SMTP Server
### Using Host User
* TODO "Add using host"
#### Install
```
$ su -
$ apt-get install postfix
```

### Using SQL for Virtual
#### Install
```
$ su -
$ apt-get install postfix postfix-mysql
```
#### Configure for SQL ([SQL-File](https://github.com/tavris/ServerManual/blob/master/Ubuntu/samples/postfix/mysql-virtual-table.sql))
- Virtual Domains Table
  ```
  CREATE TABLE `virtual_domains` (
    `idx` INT NOT NULL AUTO_INCREMENT,
    `domain` VARCHAR(255) NOT NULL,
    `isDel` ENUM('Y', 'N') DEFAULT 'N' NOT NULL,
    PRIMARY KEY (`idx`)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  ```
- Virtual User Table
  ```
  CREATE TABLE `virtual_users` (
    `idx` INT NOT NULL AUTO_INCREMENT,
    `domainIdx` INT NOT NULL,
    `usrEmail` VARCHAR(255) NOT NULL,
    `passwd` VARCHAR(255) NOT NULL,
    `isDel` ENUM('Y', 'N') DEFAULT 'N' NOT NULL,
    PRIMARY KEY (`idx`),
    UNIQUE KEY `uni_user_email` (`usrEmail`),
    FOREIGN KEY (`domainIdx`) REFERENCES virtual_domains(`idx`) ON DELETE CASCADE
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  ```
- Virtual Aliases Table
  ```
  CREATE TABLE `virtual_aliases` (
    `idx` INT NOT NULL AUTO_INCREMENT,
    `domainIdx` INT NOT NULL,
    `usrIdx` INT NOT NULL,
    `source` VARCHAR(255) NOT NULL,
    `destination` VARCHAR(255) NOT NULL,
    `isDel` ENUM('Y', 'N') DEFAULT 'N' NOT NULL,
    PRIMARY KEY (`idx`),
    FOREIGN KEY (`domainIdx`) REFERENCES virtual_domains(`idx`) ON DELETE CASCADE,
    FOREIGN KEY (`usrIdx`) REFERENCES virtual_users(`idx`) ON DELETE CASCADE
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  ```
#### Configure for postfix
- Virtual Domain Script -> [mysql-virtual-mailbox-domains.cf](https://github.com/tavris/ServerManual/blob/master/Ubuntu/samples/postfix/mysql-virtual-mailbox-domains.cf)
  ```
  user = {SQL_USER_ID}
  password = {SQL_USER_PWD}
  hosts = {SQL_SERVER_IP or 127.0.0.1}{:PORT}
  dbname = {SQL_DATABASE_NAME or mail_server}
  query = SELECT 1 FROM virtual_domains WHERE domain = '%s' AND isDel='N'
  ```
- Virtual User Script -> [mysql-virtual-mailbox-maps.cf](https://github.com/tavris/ServerManual/blob/master/Ubuntu/samples/postfix/mysql-virtual-mailbox-maps.cf)
  ```
  user = {SQL_USER_ID}
  password = {SQL_USER_PWD}
  hosts = {SQL_SERVER_IP or 127.0.0.1}{:PORT}
  dbname = {SQL_DATABASE_NAME or mail_server}
  query = SELECT 1 FROM virtual_users WHERE usrEmail = '%s' AND isDel = 'N'
  ```
- Virtual Alias Script -> [mysql-virtual-alias-maps.cf](https://github.com/tavris/ServerManual/blob/master/Ubuntu/samples/postfix/mysql-virtual-alias-maps.cf)
  ```
  user = {SQL_USER_ID}
  password = {SQL_USER_PWD}
  hosts = {SQL_SERVER_IP or 127.0.0.1}{:PORT}
  dbname = {SQL_DATABASE_NAME or mail_server}
  query = SELECT destination FROM virtual_aliases WHERE source = '%s' AND isDel = 'N'
  ```
- /etc/postfix/main.cf [Default_Template](https://github.com/tavris/ServerManual/blob/master/Ubuntu/samples/postfix/main.cf)
  ```
  smtpd_banner = $ESMTP $mail_name
  
  # TLS parameters
  ## SMTPD
  smtpd_use_tls = yes
  smtpd_tls_cert_file = {SSL_CERT_FILE_PATH}
  smtpd_tls_key_file = {SSL_KEY_FILE_PATH}
  smtpd_tls_received_header = yes
  smtpd_tls_session_cache_timeout = 3600s
  smtpd_tls_security_level = may

  ## SMTP
  smtp_use_tls = yes
  smtp_tls_CApath = {SSL_CA_FILE_PATH}
  smtp_tls_security_level = may
  smtp_tls_session_cache_database = btree:${data_directory}/smtp_scache

  ## SMTP-SASL
  smtpd_sasl_type = dovecot
  smtpd_sasl_path = private/auth
  smtpd_sasl_auth_enable = yes
  smtpd_recipient_restrictions = permit_sasl_authenticated permit_mynetworks reject_unauth_destination
  # smtpd_relay_restrictions = permit_mynetworks permit_sasl_authenticated defer_unauth_destination
  
  mydomain = {domain}
  myhostname = mail.{domain}
  myorigin = $mydomain
  mydestination = $myhostname, $mydomain, localhost.$mydomain, localhost
  
  # Mailbox
  home_mailbox = /var/mail/
  mailbox_size_limit = 0
  
  ## Virtual Mail
  virtual_transport = lmtp:unix:private/dovecot-lmtp
  virtual_mailbox_domains = mysql:/etc/postfix/mysql-virtual-mailbox-domains.cf
  virtual_mailbox_maps = mysql:/etc/postfix/mysql-virtual-mailbox-maps.cf
  virtual_alias_maps = mysql:/etc/postfix/mysql-virtual-alias-maps.cf
  ```
- /etc/postfix/master.cf [Default_Template](https://github.com/tavris/ServerManual/blob/master/Ubuntu/samples/postfix/master.cf)
  ```
  smtp      inet  n       -       n       -       -       smtpd
  
  submission inet n       -       n       -       -       smtpd
    -o syslog_name=postfix/submission
    -o smtpd_tls_security_level=encrypt
    -o smtpd_sasl_auth_enable=yes
  #  -o smtpd_tls_auth_only=yes
  #  -o smtpd_reject_unlisted_recipient=no
  #  -o smtpd_client_restrictions=$mua_client_restrictions
  #  -o smtpd_helo_restrictions=$mua_helo_restrictions
  #  -o smtpd_sender_restrictions=$mua_sender_restrictions
    -o smtpd_recipient_restrictions=permit_sasl_authenticated,reject
  #  -o smtpd_relay_restrictions=permit_sasl_authenticated,reject
    -o milter_macro_daemon_name=ORIGINATING
  # Choose one: enable smtps for loopback clients only, or for any client.
  ```
  
### POP3, IMAP
#### Install
```
$ su -
$ apt-get install dovecot
```
#### Configure
- /etc/dovecot/conf.d/10-auth.conf
  ```
  disable_plaintext_auth = yes
  auth_mechanisms = plain login

  ##
  ## Password and user databases
  ##
  #!include auth-deny.conf.ext
  #!include auth-master.conf.ext

  #!include auth-system.conf.ext
  #!include auth-sql.conf.ext
  #!include auth-ldap.conf.ext
  !include auth-passwdfile.conf.ext
  #!include auth-checkpassword.conf.ext
  #!include auth-vpopmail.conf.ext
  #!include auth-static.conf.ext
  ```

- /etc/dovecot/conf.d/10-mail.conf
  ```
  mail_location = maildir:/var/mail/%u/

  namespace inbox {
    inbox = yes
  }

  mail_privileged_group = {GROUP}
  ```

- /etc/dovecot/conf.d/10-master.conf
  ```
  service lmtp {
    unix_listener /var/spool/postfix/private/dovecot-lmtp {
      mode = 0600
      user = postfix
      group = postfix
    }
  }
  ```

- /etc/dovecot/conf.d/10-ssl.conf
  ```
  ssl = yes

  ssl_cert = <{SSL_CERT_FILE}
  ssl_key = <{SSL_KEY_FILE}
  ssl_ca = <{SSL_CA_FILE}
  ```

- /etc/dovecot/conf.d/auth-passwdfile.conf.ext
  ```
  passdb {
    driver = passwd-file
    args = scheme=PLAIN username_format=%u /etc/dovecot/users
  }

  userdb {
    driver = passwd-file
    args = username_format=%u /etc/dovecot/users
  }
  ```

## Testing
### SQL
- Virtual Domain
  ```
  postmap -q {TEST_DOMAIN} mysql:/etc/postfix/mysql-virtual-mailbox-domains.cf
  ```
- Virtual User
  ```
  postmap -q {TEST_USER} mysql:/etc/postfix/mysql-virtual-mailbox-maps.cf
  ```
- Virtual Alias
  ```
  postmap -q {TEST_USER} mysql:/etc/postfix/mysql-virtual-alias-maps.cf
  ```
## Using
### Add Email User
- /etc/dovecot/users
  ```
  {Id}:{Password}:{uid}:{gid}::::userdb_mail={Path}
  ```

## Trouble Shooting
### smtpd: connect from unknown[unknown]
- /etc/postfix/main.cf
  append 
  ```
  smtpd_client_restrictions =
        permit_mynetworks,
        reject_unauth_pipelining,
        reject_unknown_client_hostname,
        permit
  ```
  
## Refer
1. [PostfixCompleteVirtualMailSystemHowto](https://help.ubuntu.com/community/PostfixCompleteVirtualMailSystemHowto#Setting_MySQL_Backend) - Ubuntu Community
2. [Postfix](https://help.ubuntu.com/community/Postfix) - Ubuntu Community
3. [Mail Server](https://help.ubuntu.com/community/MailServer) - Ubuntu Community
4. [How to work Mail Server](https://noviceany.tistory.com/58)
5. [yiworkdisk](https://yiworkdisk.netlify.app/ko/linux/install_postfix.html)
6. [퍼니오](https://www.fun25.co.kr/blog/dovecot-postfix-mysql-mail-server)
