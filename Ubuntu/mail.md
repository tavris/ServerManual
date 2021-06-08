# DNS Setting

## Record Setting

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

# Mail Server
## SMTP

```
$ su -
$ apt-get install postfix
```

## POP3, IMAP

```
```
