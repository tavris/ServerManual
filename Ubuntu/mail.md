# Postfix & Dovecot mail server
### Environment
- ![Generic badge](https://img.shields.io/badge/UbuntU-18.04.5_LTS_or_Above-green.svg)

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
    $ nslookup mail.{DOMAIN}
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
    $ nslookup -type=mx {DOMAIN}
    Server : {Server IP}
    Address: {Server IP}#{TagNum}
    
    Non-authoritative answer:
    {domain}  mail exchanger = {Number of Priority} mail.{domain}
- **SPF Record**
  - Record Type : TXT, NAME : @, VALUE : v=spf1 ip4:{Server IP} -all
  - Test<br>
    ```
    $ nslookup -type=txt {DOMAIN}
    Server : {Server IP}
    Address: {Server IP}#{TagNum}
    
    Non-authoritative answer:
    {DOMAIN}  text = v=spf1 ip4:{Server IP} -all
    ```
- **DKIM Record**
  - Record Type : TXT, NAME : {PREFIX}.\_domainkey.{DOMAIN}
    VALUE = `DKIM Key Value`
    ```
    ## Example
    "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5iCQchVwQIUEry48m2RstfzC18sd28A94ZreIiq0pDH5on5+gkEi+vnoX124ZCiGrQ1ov6AJiJUvwcAft7suKpEMRVN983Uo29eQcxot9K/sf3UGczsr/4UhzqIfMSwGl4I3hDvb6QxqqD/rVeT3nLy6HaAqlq4gJw5LAQaHnHOxFwd4+jSMf+Xk8hHKZlOY3yorm5v0mHeEpgGTmtfl90SLbUeZF8ipJOH/4QOf7wYqHZQiJVnSL2Yp7MbZZguMYPpLc3XFDGsgcmNGFU1IAxsH+K38JEHloc2fI9iXGoOY8ae1RC5kWSbWEIkl1KptkSpogbAGqRyJYyJL6ycU5QIDAQAB"
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
  
## POP3, IMAP
### Using SQL for Virtual
#### Install
```
$ su -
$ apt-get install dovecot dovecot-imapd dovecot-lmtpd dovecot-mysql
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
  !include auth-sql.conf.ext
  #!include auth-ldap.conf.ext
  #!include auth-passwdfile.conf.ext
  #!include auth-checkpassword.conf.ext
  #!include auth-vpopmail.conf.ext
  #!include auth-static.conf.ext
  ```

- /etc/dovecot/conf.d/10-mail.conf
  ```
  # %u - username
  # %n - user part in user@domain, same as %u if there's no domain
  # %d - domain part in user@domain, empty if there's no domain
  # %h - home directory
  mail_location = maildir:/var/mail/%d/%n

  namespace inbox {
    inbox = yes
  }

  mail_privileged_group = {GROUP}
  ```

- /etc/dovecot/conf.d/10-master.conf
  ```
  service imap-login {
    inet_listener imap {
      port = 143
    }
    inet_listener imaps {
      port = 993
      ssl = yes
    }
    #service_count = 1
    #process_min_avail = 0
    #vsz_limit = $default_vsz_limit
  }
  
  service lmtp {
    unix_listener /var/spool/postfix/private/dovecot-lmtp {
      mode = 0600
      user = postfix
      group = postfix
    }
  }
  
  service auth {
    unix_listener auth-userdb {
      mode = 0666
      user = root
      #group =
    }

    # Postfix smtp-auth
    unix_listener /var/spool/postfix/private/auth {
      mode = 0666
      user = postfix
      group = postfix
    }

    #user = $default_internal_user
    user = dovecot
  }
  ```

- /etc/dovecot/conf.d/10-ssl.conf
  ```
  ssl = required:q::

  ssl_cert = <{SSL_CERT_FILE}
  ssl_key = <{SSL_KEY_FILE}
  ssl_ca = <{SSL_CA_FILE}
  ```

- /etc/dovecot/conf.d/auth-sql.conf.ext
  ```
  passdb {
    driver = sql
    args = /etc/dovecot/dovecot-sql.conf.ext
  }

  userdb {
    driver = static
    args = uid=vmail gid=vmail home=/var/mail/%d/%n
  }
  ```
  
## SPF (Sender Policy Framework)
#### Install
```
$ su -
$ apt-get install postfix-policyd-spf-python
```
#### Configure
- /etc/postfix/master.cf
```
...
## Add the following content to the bottom of the file content.
policyd-spf  unix  -       n       n       -       0       spawn
  user=policyd-spf argv=/usr/local/bin/policyd-spf
```
- /etc/postfix/main.cf
```
## SMTP-SASL
smtpd_recipient_restrictions =
  ....
  check_policy_service unix:private/policyd-spf
# SPF
policyd-spf_time_limit = 3600
```

## DKIM (DomainKeys Identified Mail)
#### Install
```
$ su -
$ apt-get install opendkim opendkim-tools
```
#### Configure
- /etc/opendkim.conf 
```
## Mode using 's' only check recive, 'sv'check send and recive.
Mode		sv
SendReports	yes

#KeyFile	/etc/opendkim/keys/default.private    [#주석 처리, 사용하지 않음]
KeyTable        /etc/opendkim/KeyTable    [#주석 제거]
SigningTable  refile:/etc/opendkim/SigningTable    [#주석 제거]
ExternalIgnoreList      refile:/etc/opendkim/TrustedHosts    [#주석 제거]
InternalHosts   refile:/etc/opendkim/TrustedHosts    [#주석 제거]
```
- /etc/opendkim/TrustedHosts
```
127.0.0.1
::1
{DOMAIN}
mail.{DOMAIN}
```
- /etc/opendkim/SigningTable
```
*@{DOMAIN} {PREFIX}._domainkey.{DOMAIN}
```
- /etc/opendkim/KeyTable
```
{PREFIX}._domainkey.{DOMAIN} DOMAIN:{PREFIX}:/etc/opendkim/keys/{DOMAIN}/{PREFIX}.private 
```
#### Build Key
```
$ su -
$ opendkim-genkey -b 2048 -d {DOMAIN} -D /etc/opendkim/keys/{DOMAIN} -s {PREFIX} -v 
$ chown opendkim:opendkim -R /etc/opendkim/keys/
$ chmod 700 /etc/opendkim/keys
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
### DKIM
* Using `opendkim-testkey` inside server.
  1. `opendkim-testkey -d {DOMAIN} -s {PREFIX} -vvv`
  2. Make sure it looks like the example data below. 
    ```
    opendkim-testkey: using default configfile /etc/opendkim.conf
    opendkim-testkey: checking key '{PREFIX}._domainkey.{DOMAIN}'
    opendkim-testkey: key not secure
    opendkim-testkey: key OK
    ```
* Using WebSite [MXToolBox](https://mxtoolbox.com/SuperTool.aspx?action).
  1. Click `DKIM Lookup` menu.
  2. Enter the hostsname : {PREFIX}.\_domainkey.{DOMAIN}
  
## Using
### Add Email User
- /etc/dovecot/users
  ```
  {Id}:{Password}:{uid}:{gid}::::userdb_mail={Path}
  ```
### DKIM
  ```
  $ su -
  $ systemctl start opendkim #→ Start Service.
  $ systemctl enable opendkim #→ Registed autometic start.
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
### SHA512-CRYPT not match
Change `SHA512-CRYPT` -> `SHA512`
In MySQL Create function.
```
CREATE FUNCTION `dovecotSHA512Pwd`(PLAIN VARCHAR(255)) RETURNS VARCHAR(512)
BEGIN
	DECLARE RETURN_VALUE VARCHAR(512);
	SET RETURN_VALUE = TO_BASE64(UNHEX(SHA2('PLAIN', 512)));
	RETURN RETURN_VALUE;
END
```
### DKIM
#### If the DNS input size is exceeded
When generating the key, you must use the default `RSA-1024` bit by excluding the `-b 2048` option.
For the purpose of applying only the DKIM policy, issue a key as follows.
```
$ su -
$ opendkim-genkey -d {DOMAIN} -D /etc/opendkim/keys -s {PREFIX} -v
```
#### Postfix: can't load key : No such file or directory
Check `/etc/opendkim/KeyTable` Setting.

#### Postfix: key data is not secure
The public key and key do not match.

#### Postfix: can't load key from : Permission denied
It is caused by a permission problem in the path `/etc/opendkim/keys/`, `/keys` folder is set to `700` permission.

## Refer
1. [PostfixCompleteVirtualMailSystemHowto](https://help.ubuntu.com/community/PostfixCompleteVirtualMailSystemHowto#Setting_MySQL_Backend) - Ubuntu Community
2. [Postfix](https://help.ubuntu.com/community/Postfix) - Ubuntu Community
3. [Mail Server](https://help.ubuntu.com/community/MailServer) - Ubuntu Community
4. [How to work Mail Server](https://noviceany.tistory.com/58)
5. [yiworkdisk](https://yiworkdisk.netlify.app/ko/linux/install_postfix.html)
6. [퍼니오](https://www.fun25.co.kr/blog/dovecot-postfix-mysql-mail-server)
7. [Rocky Linux - 메일서버 구축(Postfix, Dovecot, MariaDB And Roundcube)](https://foxydog.tistory.com/104)
8. [Rocky Linux - 메일서버(Postfix) DKIM 정책 적용](https://foxydog.tistory.com/112)
