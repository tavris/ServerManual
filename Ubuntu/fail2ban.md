# Fail2Ban
## Install
```
$ su -
$ apt-get install fail2ban
```
## Configure
### Default setting
> Copy and rename the file from jail.conf to jail.local and use it to keep the existing preference file.
* /etc/fail2ban/jail.local
  ```
  [DEFAULT]

  #Ignore baned IP.
  ignoreip = 127.0.0.1/8

  #How to long baned. (60m = 1 Hours, 525600m = 1 Year)
  bantime  = 525600m

  #Maximum re-try counts.
  maxretry = 5

  #Block if the maximum number of repetitions is exceeded within the set time.
  findtime  = 10m

  #Mail notification settings. (Optional add-ons.)
  destemail = {EMAIL_ADDRESS}
  sender = fail2ban@{SERVER_DOMAIN}
  mta = sendmail
  action = %(action_mwl)s
  ```
* /etc/fail2ban/jail.d/defaults-debian.conf
  ```
  [sshd]
  enabled = true
  
  [{JAIL_RULE_NAME}]
  enabled = {true or false}
  ```

### Jail filter setting
Add `{JAIL_RULE_NAME}.conf` file under `/etc/fail2ban/filter.d/` folder.
```
[Definition]
failregex = {Regex}
ignoreregex = {Regex}
```
