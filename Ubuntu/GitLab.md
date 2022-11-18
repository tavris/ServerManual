# GitLab
### Environment
- ![Generic badge](https://img.shields.io/badge/UbuntU-22.04_LTS_or_Above-green.svg)
-----
## Install
### Install dependency package
```
$ su -
$ apt-get install tzdata curl ca-certificates
```
### Add GitLab CE repos
```
curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
```
### Install GitLab CE
```
apt-get install gitlab-ce
```
-----
## Configure
> Must use be root.
* /etc/gitlab/gitlab.rb
  ```
  external_url = {EXTERNAL_URL}
  
  git_data_dirs({
    "default" => {
      "path" => "{GIT_DATA_PATH}"
    }
  })
  ```
## Useage
### GitLab Service
* Reconfigure GitLab
  ```
  $ su -
  $ gitlab-ctl reconfigure
  ```
* Check GitLab service
  ```
  $ su -
  $ sudo gitlab-ctl status
  ```
## Troubleshooting
