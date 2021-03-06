# My Ansible playbooks

This repository contains [Ansible] playbooks to set up my computing devices
(workstation, notebook and arm based boxes). These playbooks assume you are
running Arch Linux. Eventually I hope to add ubuntu/debian compatibility.

This repo is not yet stable and it has gone though heavy refactory lately. Here
you will find some dragons, you have been warned!


## Metrics

[![Travis-CI](https://img.shields.io/travis/vonpupp/dotfiles-ansible.svg)](https://travis-ci.org/vonpupp/dotfiles-ansible)
[![Stories in Ready](https://badge.waffle.io/vonpupp/dotfiles-ansible.png?label=ready&title=Ready)](http://waffle.io/vonpupp/dotfiles-ansible)
[![Stories in progress](https://badge.waffle.io/vonpupp/dotfiles-ansible.png?label=progress&title=Progress)](http://waffle.io/vonpupp/dotfiles-ansible)

Throughput Graph

[![Throughput Graph](https://graphs.waffle.io/vonpupp/dotfiles-ansible/throughput.svg)](https://waffle.io/vonpupp/dotfiles-ansible/metrics)


## Requirements

- Git
- Ansible
- The VM *must* have more than 512Mb of RAM (asdf-vm for ruby requires it)
- /tmp must be bigger than 256Mb (asdf-vm for ruby requires it)
  - Can be remounted with `expand-tmp-size.sh` on the `scripts` folder


## Usage

The dependencies are: Ansible and Git.

### HD Preparation

```bash
# If you need to resize the root partition during live boot for install
mount -o remount,size=4G /run/archiso/cowspace

# Clone the installer repo
pacman -Syy git --noconfirm
git clone https://github.com/vonpupp/arch-installer
cd arch-installer
git checkout feature/efi-crypt
cd cryptlvm
./bootstap.sh
cd ..
./archinstaller

# Recreate the ramdisk (bug on archinstaller)
cd cryptlvm
./05-mount.sh
cd ..
# Edit /mnt/etc/mkinitcpio.conf
# Add the following hooks (in this order):
# base udev autodetect modconf block keymap encrypt lvm2 filesystems keyboard fsck
arch-chroot /mnt mkinitcpio -p linux
cd cryptlvm
./06-umount.sh
```

### Ansible use

```bash
# (deprecated) If you need to expand the tmp size:
./expand-tmp-size.sh

# (deprecated) If you need to install the dependencies on Arch Linux
./archlinux/setup-archlinux-dependencies.sh

# Bootstrap the playbook (as your user), optionally you can use only some tags and variables
mkdir -p .homesick/repos
cd .homesick/repos
git clone https://github.com/vonpupp/dotfiles-ansible
cd dotfiles-ansible/home/.ansible-dotfiles

# (as root) Bootstrap root (this will create a user and add it to the sudoers group)
./setup-root.sh
logout

# (as user) Bootstrap the playbook
mkdir -p .homesick/repos
cd .homesick/repos
git clone https://github.com/vonpupp/dotfiles-ansible
cd dotfiles-ansible/home/.ansible-dotfiles
sudo ansible-playbook playbook-stage1.yml -i local, -c local --sudo -e is_travis=false
sudo ansible-playbook playbook-stage2.yml -i local, -c local --sudo -e is_travis=false
sudo ansible-playbook playbook-stage3.yml -i local, -c local --sudo -e is_travis=false -e user=$USER -t dotfiles_zsh
logout

# (as user) With zsh
sudo ansible-playbook playbook-stage3.yml -i local, -c local --sudo -e is_travis=false -e user=$USER --ask-vault-pass -t os_secrets_pre
sudo systemctl enable autofs
sudo systemctl start autofs

sudo ansible-playbook playbook-stage3.yml -i local, -c local --sudo -e is_travis=false -e user=$USER --ask-vault-pass
sudo ansible-playbook playbook-stage4.yml -i local, -c local --sudo -e is_travis=false -e user=$USER --ask-vault-pass

# Alternatively you can bootstrap as another user, or a specific tag
sudo ansible-playbook playbook-stage3.yml -i local, -c local --sudo -e is_travis=false -e user=av -t os_secrets [--ask-vault-pass]
sudo ./setup-user.sh -e is_travis=false [-e user=$USER] [-t tags]
```

### Further configs

* Dropbox
* Change hostname
* Change passwords

## Parts, labels and roles

I am waiting for an official ansible automatic documentation system, until
then, read the code. You can query tags by using:

```
ansible-playbook --list-tags playbook.yml
```

Tags should be self explanatory. I divided them into several main groups; the
groups are identified by prefixes:
- `packages_cui_*`. Installs a list of system packages (cui packages only).
- `packages_gui_*`. Installs a list of system packages (gui packages only).
- `packages_cui_aur_*`. Installs a list of aur packages (cui packages only).
- `packages_gui_aur_*`. Installs a list of aur packages (gui packages only).
- `devel_env_*`. Installs a development environment.
- `dotfiles_*`. Installs my dotfiles.

| tag (packages)                 | Status                                            |
|--------------------------------|---------------------------------------------------|
| `upgrade`                      | [![Travis-CI](https://travis-matrix-badges.herokuapp.com/repos/vonpupp/dotfiles-ansible/branches/master/1)](https://travis-ci.org/vonpupp/dotfiles-ansible)
| `packages_cui_minimal`         | [![Travis-CI](https://travis-matrix-badges.herokuapp.com/repos/vonpupp/dotfiles-ansible/branches/master/2)](https://travis-ci.org/vonpupp/dotfiles-ansible)
| `packages_cui_workstation`     | [![Travis-CI](https://travis-matrix-badges.herokuapp.com/repos/vonpupp/dotfiles-ansible/branches/master/3)](https://travis-ci.org/vonpupp/dotfiles-ansible)
| `packages_gui_xorg`            | [![Travis-CI](https://travis-matrix-badges.herokuapp.com/repos/vonpupp/dotfiles-ansible/branches/master/4)](https://travis-ci.org/vonpupp/dotfiles-ansible)
| `packages_gui_awesome_wm`      | [![Travis-CI](https://travis-matrix-badges.herokuapp.com/repos/vonpupp/dotfiles-ansible/branches/master/5)](https://travis-ci.org/vonpupp/dotfiles-ansible)
| `packages_gui_fonts`           | [![Travis-CI](https://travis-matrix-badges.herokuapp.com/repos/vonpupp/dotfiles-ansible/branches/master/6)](https://travis-ci.org/vonpupp/dotfiles-ansible)
| `packages_gui_apps`            | [![Travis-CI](https://travis-matrix-badges.herokuapp.com/repos/vonpupp/dotfiles-ansible/branches/master/7)](https://travis-ci.org/vonpupp/dotfiles-ansible)

| Writing suite                  | Status                                            |
|--------------------------------|---------------------------------------------------|
| `packages_suite_latex`         | [![Travis-CI](https://travis-matrix-badges.herokuapp.com/repos/vonpupp/dotfiles-ansible/branches/master/8)](https://travis-ci.org/vonpupp/dotfiles-ansible)
| `packages_suite_libreoffice`   | [![Travis-CI](https://travis-matrix-badges.herokuapp.com/repos/vonpupp/dotfiles-ansible/branches/master/9)](https://travis-ci.org/vonpupp/dotfiles-ansible)

| OS                             | Status                                            |
|--------------------------------|---------------------------------------------------|
| `os_locale`                    | [![Travis-CI](https://travis-matrix-badges.herokuapp.com/repos/vonpupp/dotfiles-ansible/branches/master/10)](https://travis-ci.org/vonpupp/dotfiles-ansible)
| `os_hostname`                  | [![Travis-CI](https://travis-matrix-badges.herokuapp.com/repos/vonpupp/dotfiles-ansible/branches/master/11)](https://travis-ci.org/vonpupp/dotfiles-ansible)
| `os_pacman`                    | [![Travis-CI](https://travis-matrix-badges.herokuapp.com/repos/vonpupp/dotfiles-ansible/branches/master/12)](https://travis-ci.org/vonpupp/dotfiles-ansible)
| `os_service_networkmanager`    | [![Travis-CI](https://travis-matrix-badges.herokuapp.com/repos/vonpupp/dotfiles-ansible/branches/master/13)](https://travis-ci.org/vonpupp/dotfiles-ansible)
| `os_service_dnsmasq`           | [![Travis-CI](https://travis-matrix-badges.herokuapp.com/repos/vonpupp/dotfiles-ansible/branches/master/14)](https://travis-ci.org/vonpupp/dotfiles-ansible)
| `os_service_ntp`               | [![Travis-CI](https://travis-matrix-badges.herokuapp.com/repos/vonpupp/dotfiles-ansible/branches/master/15)](https://travis-ci.org/vonpupp/dotfiles-ansible)
| `os_service_ufw`               | [![Travis-CI](https://travis-matrix-badges.herokuapp.com/repos/vonpupp/dotfiles-ansible/branches/master/16)](https://travis-ci.org/vonpupp/dotfiles-ansible)
| `os_service_ssh`               | [![Travis-CI](https://travis-matrix-badges.herokuapp.com/repos/vonpupp/dotfiles-ansible/branches/master/17)](https://travis-ci.org/vonpupp/dotfiles-ansible)
| `os_service_docker`            | [![Travis-CI](https://travis-matrix-badges.herokuapp.com/repos/vonpupp/dotfiles-ansible/branches/master/18)](https://travis-ci.org/vonpupp/dotfiles-ansible)
| `os_service_kvm`               | [![Travis-CI](https://travis-matrix-badges.herokuapp.com/repos/vonpupp/dotfiles-ansible/branches/master/19)](https://travis-ci.org/vonpupp/dotfiles-ansible)

| AUR                            | Status                                            |
|--------------------------------|---------------------------------------------------|
| `yaourt`                       | [![Travis-CI](https://travis-matrix-badges.herokuapp.com/repos/vonpupp/dotfiles-ansible/branches/master/20)](https://travis-ci.org/vonpupp/dotfiles-ansible)
| `packages_cui_aur`             | [![Travis-CI](https://travis-matrix-badges.herokuapp.com/repos/vonpupp/dotfiles-ansible/branches/master/21)](https://travis-ci.org/vonpupp/dotfiles-ansible)
| `packages_gui_aur`             | Takes longer than 90min on Travis

| Devel                          | Status                                            |
|--------------------------------|---------------------------------------------------|
| `devel_env_python`             | [![Travis-CI](https://travis-matrix-badges.herokuapp.com/repos/vonpupp/dotfiles-ansible/branches/master/22)](https://travis-ci.org/vonpupp/dotfiles-ansible)
| `devel_env_ruby`               | [![Travis-CI](https://travis-matrix-badges.herokuapp.com/repos/vonpupp/dotfiles-ansible/branches/master/23)](https://travis-ci.org/vonpupp/dotfiles-ansible)
| `devel_env_node`               | [![Travis-CI](https://travis-matrix-badges.herokuapp.com/repos/vonpupp/dotfiles-ansible/branches/master/24)](https://travis-ci.org/vonpupp/dotfiles-ansible)
| `devel_env_java`               | Todo
| `devel_env_r`                  | [![Travis-CI](https://travis-matrix-badges.herokuapp.com/repos/vonpupp/dotfiles-ansible/branches/master/25)](https://travis-ci.org/vonpupp/dotfiles-ansible)
| `devel_env_haskell`            | [![Travis-CI](https://travis-matrix-badges.herokuapp.com/repos/vonpupp/dotfiles-ansible/branches/master/26)](https://travis-ci.org/vonpupp/dotfiles-ansible)

| Dotfiles                       | Status                                            |
|--------------------------------|---------------------------------------------------|
| `dotfiles_home`                | [![Travis-CI](https://travis-matrix-badges.herokuapp.com/repos/vonpupp/dotfiles-ansible/branches/master/27)](https://travis-ci.org/vonpupp/dotfiles-ansible)
| `dotfiles_apps`                | [![Travis-CI](https://travis-matrix-badges.herokuapp.com/repos/vonpupp/dotfiles-ansible/branches/master/28)](https://travis-ci.org/vonpupp/dotfiles-ansible)
| `dotfiles_tmux`                | [![Travis-CI](https://travis-matrix-badges.herokuapp.com/repos/vonpupp/dotfiles-ansible/branches/master/29)](https://travis-ci.org/vonpupp/dotfiles-ansible)
| `dotfiles_vim`                 | [![Travis-CI](https://travis-matrix-badges.herokuapp.com/repos/vonpupp/dotfiles-ansible/branches/master/30)](https://travis-ci.org/vonpupp/dotfiles-ansible)
| `dotfiles_zsh`                 | [![Travis-CI](https://travis-matrix-badges.herokuapp.com/repos/vonpupp/dotfiles-ansible/branches/master/31)](https://travis-ci.org/vonpupp/dotfiles-ansible)
| `dotfiles_awesome`             | [![Travis-CI](https://travis-matrix-badges.herokuapp.com/repos/vonpupp/dotfiles-ansible/branches/master/32)](https://travis-ci.org/vonpupp/dotfiles-ansible)
| `dotfiles_task`                | [![Travis-CI](https://travis-matrix-badges.herokuapp.com/repos/vonpupp/dotfiles-ansible/branches/master/33)](https://travis-ci.org/vonpupp/dotfiles-ansible)
| `dotfiles_fortune_bible`       | [![Travis-CI](https://travis-matrix-badges.herokuapp.com/repos/vonpupp/dotfiles-ansible/branches/master/34)](https://travis-ci.org/vonpupp/dotfiles-ansible)


### (Optional) Mounting a local NFS packages cache (optional)

To save time and bandwidth a NFS packages cache can be optionally mounted (as
root) prior installation with:

```bash
pacman -Sy --noconfirm nfs-utils
mount -t nfs -o nolock,vers=3 nas:/share/cache/arch/$(uname -m)/var/lib/pacman/sync /var/lib/pacman/sync
mount -t nfs -o nolock,vers=3 nas:/share/cache/arch/$(uname -m)/var/cache/pacman/pkg /var/cache/pacman/pkg
```


## TODOs

- [X] Parallelized Travis running test
- [X] Enable zsh by default on dotfiles-zsh
- [X] Change all dotfiles repos to git instead of https as in dotfiles-awesome4
- [X] Fix gpg recv-key glitch on stage1
- [X] Fetch known_hosts keys
- [ ] Restart systemd services
- [ ] Add git authorized keys
- [ ] Check fzf freeze
- [ ] Add https://github.com/martini97/pomobash
- [ ] Add Zeal docs
- [ ] Migrate to pacaur


## Inspiration

* https://github.com/cdown/ansible-personal
* https://github.com/pigmonkey/spark
* https://github.com/jsok/dotfiles
* https://github.com/cturner80/digital-ocean-ansible
* https://github.com/augustl/ansible-playbooks
* https://github.com/vvo/ansible-archee/tree/master/roles/user/tasks
* https://github.com/resmo/ansible-role-sshd
* https://github.com/ajsalminen/ansible-role-cheat

[Ansible]: http://ansible.com

<!--  vim: set spell: -->
<!--  vim: set spelllang=en_us: -->
