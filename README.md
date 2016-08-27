# ansible-playbooks
Alexandre de Verteuil's Ansible playbooks and roles

This is the set of Ansible playbooks and roles I use to manage my home
network. I find it helpful to read other people's playbooks and roles,
but even those ones published on Galaxy aren't general enough to just
use them as-is. I also think portability makes roles ugly. I din't make
an effort to split the roles in their own repository because I believe
you will do the same: look at them and take what you find useful to
write your own roles.

Instead of an all-in-one home router, I have a 16 GB, quad-core 3.1
GHz E3, dual-gigabit, virtualisation server running libvirt to manage
KVM ultraspecialized guests, one for each service (for security and
simplicity). They are all running on Debian 8 except the FreeIPA server
which is Fedora Server.
