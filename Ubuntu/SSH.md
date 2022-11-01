# Apache2
### Environment
- ![Generic badge](https://img.shields.io/badge/UbuntU-18.04_or_Above-green.svg)

## Setting
- /etc/ssh/sshd_config
```
Prot 22

...

UsePAM yes

...

X11Forwarding yes

...

PrintMotd no

...

AcceptEnv LANG LC_*

...

Subsystem       sftp    /usr/lib/openssh/sftp-server
```
