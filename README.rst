=======
cloudMe
=======

TL;DR
=====

cloudMe is a set of tools to run a mini-cloud on your machine based on kvm / qemu and written in bash.

To create a template and instanciate 5 times this template ::

 vmcreate -n debian8 -i debian-8.6.0-amd64-netinst.iso
 vminstantiate -n debian8 -C 5

Presentation
============

cloudMe is a cheap solution to own your cloud. It was first developped as a side project to provide the tools I needed for my virtualbox usage. I switched to kvm backend but keeping in mind the possibility to offer multiple backends.

it is :

- modular (composed of multiple simple and one-task-only command-line tools)
- using kvm to manage vms
- using ansible to configure vms

it is not :

- ment to be a production cloud platform
- bug free

I therefore only have tested with Archlinux hosts. Debian and Archlinux guests were tested. And this is what will be use next as examples. Examples will be simple. Multiple options are available and are documented through the -h option of each script.

System pre-requisites
=====================

Following things needs to be installed on your machine :

- qemu
- dnsmasq
- make

kvm_intel module must be passed an option. This can be done with the following ::

 sudo echo options kvm_intel nested=1 > /etc/modprobe.d/kvm.conf

Network pre-requisites
======================

The solution is based on bridging capability. Setup needs root access and I want to reduce sudo commands through the tools at its minimum. Needs are explained below.

If you want to keep it simple, a basic configuration can be done using the script cmnet (eun as root) from sbin directory ::

 sudo sbin/cmnet start
 sudo sbin/cmnet stop

It brings the bridge0 interface up and launches dnsmasq.

Qemu configuration
------------------

The file /etc/qemu/bridge.conf determines which bridge interface QEMU is allowed to use. To simplify, we will allow all (You can be more restrictive if needed). Configuration is done, running this commands as root ::

 mkdir -p /etc/qemu
 echo "allow all" >> /etc/qemu/bridge.conf
 chown -R root:kvm /etc/qemu
 chmod 750 /etc/qemu
 chmod 640 /etc/qemu/bridge.conf

Bridge interface
----------------

At least on bridge interface must exist on your system. For the default configuration, this is done with the following commands ::

 ip link add name bridge0 type bridge
 ip link set bridge0 up
 ip addr add 192.168.1.1/24 dev bridge0

If you, as I do, use iptables on your machine, this new interface must be configured in order to access read network through the host ::

 sysctl -q net.ipv4.conf.all.forwarding=1
 iptables -I INPUT -i bridge0 -j ACCEPT
 iptables -N fw-interfaces
 iptables -A FORWARD -j fw-interfaces
 iptables -A fw-interfaces -i bridge0 -j ACCEPT
 iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o bond0 -j MASQUERADE

dnsmasq
-------

Finaly, to configure network easily on the machines, we use dnsmasq ::

 dnsmasq --interface=bridge0 --bind-interfaces --dhcp-range=192.168.1.2,192.168.1.254

Installation
============

Only thing to do is ::

 sudo make

Cloud initialization and template managment
===========================================

Everything starts with a template.

You first need to have an ISO of the system you want to install (ex: archlinux.iso). You then create a VM using this ISO ::

 ./vmcreate -n archlinux -i archlinux.iso

Once the machine created, it will start and you will have to make your template corresponding to the following standards :

- VM must be accessible through ssh
- .ssh_key.pub (created by vmCreate) must be added to root's .authorized_keys
- python must be installed
- network is using dhcp

You can create as much templates as you want.

Note that vmCreate can also be used to adjust VM configuration (using -a switch). VM must be powered off first.

Clone generation
================

Manual
------

Once your template is good, you can use it to generate new VMs ::

 ./vminstantiate -n archlinux -C 2

will create two new machines, fresh copies from of the template. Those machines will have generated names and the template's disk is set to read-only before creating the clones. The clones will run without graphical interface.

Using description file
----------------------

If you want to automate the creation of a set of VMs, you can create description files. Each line matches a vminstantiate command line parameters. Those are separated by ":" and are in the following order :

- template name
- number of clones
- group name
- type name

For instance the following file produces 2 VMs of type web and 1 VM of type sql in the group pf1 ::

 archlinux:2:pf1:web
 archlinux:1:pf1:sql

The file (named pftest) is called with the following command ::

 vminstantiate -f pftest

Tools
=====


vm - run and connect to a VM
----------------------------



vmcreate - VM creation
----------------------



vminstantiate - making clones
-----------------------------



vmlaunch - run all the VMs of a group
-------------------------------------



vmrunning - list all the running guests on the host
---------------------------------------------------



vmstop - stop a group of VMs
----------------------------
