# Vagrant

> Vagrant is a tool for building and managing virtual machine environments in a single workflow.

- https://www.vagrantup.com/

## Virtual Machine

- Meme version et configuration qu'une machine cible

## Setup

- [virtualbox.org](https://www.virtualbox.org/wiki/Downloads)
- [vagrantup.com](https://www.vagrantup.com/downloads)
- [berkshelf](https://docs.chef.io/workstation/berkshelf/)

```shell
vagrant -v
```

- `search ` https://www.dev-metal.com/list-downloadable-vagrant-boxes-centos-5-9-6-4-ubuntu-12-13-debian-6-7-7-1-7-2/
- https://stackoverflow.com/questions/52296261/how-to-resolve-error-in-running-vagrant-up-on-macos

```shell
# vagrant init tuto https://s3-eu-west-1.amazonaws.com/ffuenf-vagrant-boxes/debian/debian-7.2.0-amd64.box
vagrant init debian/contrib-jessie64
vagrant up
vagrant halt
vagrant plugin install vagrant-berkshelf   # Chef vs. Berkshelf: https://github.com/berkshelf/vagrant-berkshelf
vagrant plugin install vagrant-omnibus     # https://github.com/chef-boneyard/vagrant-omnibus 
vagrant plugin install vagrant-hostmanager # https://github.com/devopsgroup-io/vagrant-hostmanager 
```


## Configuration

- https://gitlab.com/lucj/docker-exercices/-/blob/master/04.Plateforme/vagrant.md

Setup:
```shell
brew install vagrant
```

Create a `Vagrantfile`:
```
Vagrant.configure("2") do |config|
  config.vm.box = "hashicorp/bionic64"
  config.vm.network "private_network", ip: "192.168.33.11"
  config.vm.provision "shell", inline: <<-SHELL
    curl -sSLf https://get.docker.com | sh
    sudo usermod -aG docker vagrant
  SHELL
end
```

Then run:

```shell
vagrant up
vagrant ssh
vagrant@vagrant:~$ docker info
vagrant destroy -f
```
