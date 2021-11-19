# Postfix & Dovecot mail server
## Environment
- OS : Linux 18.04.5 LTS

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

## Mail Server
### Port List
  - SMTP : TCP 25, 465(SSL) or 587(SSL)
  - POP3 : TCP 110, 995(SSL)
  - IMAP : TCP 143, 993(SSL)

### SMTP
#### Install
```
$ su -
$ apt-get install postfix
```
#### Configure
- /etc/postfix/main.cf
  ```
  mydomain = {domain}
  myhostname = mail.{domain}
  myorigin = $mydomain
  mydestination = $myhostname, $mydomain, localhost.$mydomain, localhost

  smtpd_tls_cert_file = {SSL_CERT_FILE}
  smtpd_tls_key_file = {SSL_KEY_FILE}

  # Mail to be forwarded when email does not exist.
  luser_relay = {email}
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
