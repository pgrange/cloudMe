=======
nocloud
=======

TL;DR
=====

nocloud is a set of tools to run a mini-cloud on your machine based on kvm / qemu and written in bash.

To get a template and instanciate 5 times this template ::

 vmtemplate debian8
 vminstantiate -n debian8 -C 5

Presentation
============

nocloud is a cheap solution to own your cloud. It was first developped as a side project to provide the tools I needed for my virtualbox usage. I switched to kvm backend but keeping in mind the possibility to offer multiple backends.

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

Network
=======

Configuration
-------------

The solution is based on bridging capability. Setup needs root access and I want to reduce sudo commands through the tools at its minimum. Needs are explained below.

During installation, 2 services are created :

- nocloud-bridge which creates a bridge interface
- nocloud-dnsmasq brings a dnsmasq server up to serve DHCP and DNS to the machines

The configuration file /etc/qemu/bridge.conf is also created during installation. It allows qemu to bring machines interfaces connected to the bridge inteface.

Installation also configures the kvm_intel and vhost_net modules.

firewalling
-----------

If you, as I do, use iptables on your machine, the bridge interface created by cmnet must be configured in order to access read network through the host ::

 sysctl -q net.ipv4.conf.all.forwarding=1
 iptables -I INPUT -i nocloud -j ACCEPT
 iptables -N fw-interfaces
 iptables -A FORWARD -j fw-interfaces
 iptables -A fw-interfaces -i nocloud -j ACCEPT
 iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o bond0 -j MASQUERADE

If you change your configuration in /usr/local/bin/etc/nocloud_net.conf, you will need to adapt the above line (interface name, subnet...)

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
- network is using dhcp
- python is better to be installed has ansible is the tool of choice to operate on those VMs

You can create as much templates as you want.

Note that vmcreate can also be used to adjust VM configuration (using -a switch). VM must be powered off first.

Template downloading
====================

You can download existing templates using this ::

 ./vmtemplate archlinux

available templates can be listed with -h option

Clone generation
================

Manual
------

Once your template is good, you can use it to generate new VMs ::

 ./vminstantiate -n archlinux -C 2

will create two new machines, fresh copies from of the template. Those machines will have generated names and the template's disk is set to read-only before creating the clones. The clones will run without graphical interface.

In order to organize your VMs they are grouped. This is done using a two level hierarchy :

- groups will represent a kind of platform, a set of machines you use for a service.
- types will be subgroups of servers that will group VMs by function.

When nothing is specified, using vminstanciate, machines will be created in group "group" and of type "default".

Using description file
----------------------

If you want to automate the creation of a set of VMs, you can create description files. Each line matches a vminstantiate command line parameters. Those are separated by ":" and are in the following order :

- template name
- number of clones
- type name

The group of machines will be deduced from the file name.

For instance the following file produces 2 VMs of type web and 1 VM of type sql ::

 archlinux:1:sql
 archlinux:2:web

You can specify cpu and memory for each line using the following syntax ::

 archlinux:1:sql:mem=1024;cpu=4
 archlinux:2:web:mem=512

You can also add additional disks for VMs with the dsk option (sizes in GB) ::

 archlinux:1:sql:mem=1024;cpu=4;dsk=5,5
 archlinux:2:web:mem=512

If you want your machines to have more human-friendly names (instead of UUIDs), specify a name prefix ::

 archlinux:1:sql:mem=1024;cpu=4;name=db
 archlinux:2:web:mem=512;name=web

This will create a server called db00 for the first line and two servers on the second, called web00 and web01.

The file (named pftest) is called with the following command ::

 vminstantiate -f pftest

And so the machines will be in the pftest group.

Groups and types, besides being structural in the VM directory structure, and for naming purpose, will be used for instance if you configure those machines with ansible. Once the previous instanciation has been done, you can use dynamic inventory ::

 vminventory --list
 {
   "pftest_sql" : {
     "hosts" : [  "192.168.1.176", ],
   },
   "pftest_web" : {
     "hosts" : [  "192.168.1.19", "192.168.1.23", ],
   },
   "pftest" : {
     "children" : [ "pftest_sql", "pftest_web", ],
     "vars": {
       "ansible_ssh_common_args": "-o StrictHostKeyChecking=no",
       "ansible_user": "root",
     },
   },
 }

You can then stop your VMs using (-d option destroys the machines) ::

 vmstop -d -g pftest

Alternatively, you can launch your description file using ::

 vmrun -f pftest

It will stay in foreground and log (hopefuly) useful information until you press ^C which will make it kill and destroy all its machines.

Tools
=====


vm - run and connect to a VM
----------------------------



vmcreate - VM creation
----------------------



vminstantiate - making clones
-----------------------------



vmrun - run all the VMs of a group
-------------------------------------



vmrunning - list all the running guests on the host
---------------------------------------------------



vmstop - stop a group of VMs
----------------------------
