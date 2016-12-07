=======
cloudMe
=======

cloudMe is a cheap solution to own your cloud. It was first developped as a side project to provide the tools I needed for my virtualbox usage. I switched to kvm backend but keeping in mind the possibility to offer multiple backends.

it is :

- modular (composed of multiple simple and one-task-only command-line tools)
- using kvm to manage vms
- using ansible to configure vms

it is not :

- ment to be a production cloud platform
- bug free

I therefore only have tested with Archlinux hosts. Debian and Archlinux guests were tested. And this is what will be use next as examples. Examples will be simple. Multiple options are available and are documented through the -h option of each script.

Cloud initialization and template managment
===========================================

Everything starts with a template.

You first need to have an ISO of the system you want to install (ex: archlinux.iso). You then create a VM using this ISO ::

 ./vmCreate -n archlinux -i archlinux.iso

Once the machine created, it will start and you will have to make your template corresponding to the following standards :

- VM must be accessible through ssh
- .ssh_key.pub (created by vmCreate) must be added to root's .authorized_keys
- python must be installed
- network is using dhcp

You can create as much templates as you want.

Note that vmCreate can also be used to adjust VM configuration (using -a switch). VM must be powered off first.

Clone generation
================

Once your template is good, you can use it to generate new VMs ::

 ./vmInstanciate -n archlinux -C 2

will create two new machines, fresh copies from of the template. Those machines will have generated names and the template's disk is set to read-only before creating the clones. The clones will run without graphical interface.

Tools
=====

vmCreate - VM creation
----------------------



vm - running a VM
-----------------



vmInstanciate - making clones
-----------------------------
