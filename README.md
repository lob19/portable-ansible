# Self-contained Ansible distribution

Ansible package with required python modules. No need to install, just download, unpack and use. The main idea of this package is to run Ansible playbooks on local machine.

The distribution contains only `ansible-base`. The extra dependencies will need to be installed manually. 

## Changelog

All notable changes to this project are documented in the file CHANGELOG.md

## How to install and use

Latest version of portable-ansible tarball (.tar.bz2) is available on
Releases page https://github.com/ownport/portable-ansible/releases

```sh
wget https://github.com/ownport/portable-ansible/releases/download/<version>/portable-ansible-<version>-py3.tar.bz2 \
      -O ansible.tar.bz2

tar -xjf ansible.tar.bz2

python3 ansible localhost -m ping
 [WARNING]: provided hosts list is empty, only localhost is available

localhost | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

### Hints

If you need to run ansible playbooks, after having extracted the tarball contents run next commands to create aliases to portable ansible directory. In the examples below `portable-ansible` installed in `/opt` directory
```sh
python3 ansible-playbook playbook.yml
```

To have all the ansible commands, run:
```sh
for l in config console doc galaxy inventory playbook pull vault;do
  ln -s ansible ansible-$l
done
```

## Supporting additional python packages

Install python packages into `ansible/extras` directory
```
pip3 install -t ansible/extras <package>
```
or 
```
pip3 install -t ansible/extras -r requirements.txt
```

Instead of installing the python packages to `ansible/extras`, you can also install them in user directory to be available for ansible:
```
pip3 install --user -r requirements.txt
```

## For developers

Please check [this guideline](docs/development.md)

## References

- [ansible/ansible](https://github.com/ansible/ansible) Ansible is a radically simple IT automation platform that makes your applications and systems easier to deploy. Avoid writing scripts or custom code to deploy and update your applications— automate in a language that approaches plain English, using SSH, with no agents to install on remote systems. http://ansible.com/
- [ansible/ansible-modules-core](https://github.com/ansible/ansible-modules-core) Ansible modules - these modules ship with ansible
- [ansible/ansible-modules-extras](https://github.com/ansible/ansible-modules-extras) Ansible extra modules - these modules ship with ansible
