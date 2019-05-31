[![Build Status](https://travis-ci.org/ChinChihFeng/tomcat.svg?branch=master)](https://travis-ci.org/ChinChihFeng/tomcat)

# Summary

This Ansible role have the following features for installing tomcat of version 8.

 - Support `APR` on CentOS 7
 - Complie with newer version of openssl
 - Customize server configurations

This role is tested by travis ci, and it would install oracle java jdk first. If you want to test this role, you must install java on your environment first. Default version of oracle java jdk is `8u161`. The version of openssl is `1.1.1e`.

## Usage

ansible-playbook sample.yml

```yaml
---
- hosts: all

  roles:
    - tomcat_apr
```

## Role Variables


### Optional variables

```yaml
---
- hosts: tomcat-servers
  vars:
    - enable_APR: false
    - enable_threadpool: false
  roles:
    - tomcat_apr
```

### To Do
 - Verifing and testing the role on diffetent versions of java. It will support more different versions in the future
 - More easy to maintain configurations
 - Parameterize roles and playbook, and integrate into CI/CD

