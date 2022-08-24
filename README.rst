.. image:: https://github.com/ktdreyer/koji-playbooks/workflows/tests/badge.svg
             :target: https://github.com/ktdreyer/koji-playbooks/actions

Ansible playbook(s) for automating the `Koji server install process
<https://docs.pagure.org/koji/server_howto/>`_.

This sets up the Kerberos (GSSAPI) method of authentication. I use this to
quickly set up Koji in VMs in OpenStack.

Playbooks
---------

* ``setup-koji.yml`` - Installs and configures a Kerberos KDC, koji-hub, and
  koji-builder.

Run this playbook on a RHEL or CentOS 7 or 8 host with EPEL enabled. /mnt/koji
should be a disk with plenty of space.

SSL configuration
-----------------

* This playbook generates an SSL CA and keypair using the `koji-ssl-admin tool
  <https://pagure.io/koji-tools/blob/master/f/src/bin/koji-ssl-admin>`_ .

  The Certificate Authority keypair:
    * ``/etc/pki/koji/koji-ca.crt``
    * ``/etc/pki/koji/koji-ca.key``

  The Apache web server HTTPS keypair (signed by koji-ca above):
    * ``/etc/pki/koji/kojidev.example.com.chain.crt``
    * ``/etc/pki/koji/kojidev.example.com.key``

  For GSSAPI (Kerberos) authentication, these are the only SSL certs you will
  need.

  The koji-hub role publishes the Koji CA at the following URL:
  https://kojidev.example.com/kojifiles/koji-ca.crt . External Koji clients
  can download this file to verify the HTTPS connections.


Develop environment
-----------------
This is interactive deployment, where every change in source code is
automatically applied in the deployed VM.

Steps to setup:

* Clone koji `CODE
  <https://pagure.io/koji/commits/koji-1.29-updates>`_
* Change path to your cloned koji code in Vagrant file (``DEV_ENV_PATH`` var
  in ``VAGRANTFILE``)
* Deploy VM with vagrant

Important information:

* Source code version must match installed one. (That's because installed
  koji python pkg will be mismatched). This can be avoided by adding
  ``/opt/koji/koji`` to ``PYTHONPATH`` by editing kojiweb.conf (not tested)

  Example:

  ``WSGIDaemonProcess koji lang=C.UTF-8 python-home=/path/to/project/venv``

  or just replacing installed koji by linking it to ``/opt/koji/koji``.

* Every change to kojihub or kojid will also affect the deployed environment.
  Changes to kojid source code, while some tasks are executing, will result in
  failure (kojid will be automatically restarted). The same applies to kojihub.
* Due to the nature of how local files are connected with VM (via NFS) we have
  some limitations. It is not possible to monitor changes to files/folder via
  inotify, as a result we cannot use systemd path to handle monitor/restarts
  (which would be ideal for that) and instead we need to use really 'hacky' bash
  scripts to handle this.* Deployment was updated to use Fedora system with
  disabled SElinux.

What is covered by interactive deployment:

* kojihub
* kojiweb
* kojid

What is not covered by interactive deployment:

* koji (Adding ``PYTHONPATH`` by python-home in WSGIDaemonProcess needs to be tested)


Hard-coded things
-----------------

This is a santized code drop from a set of internal playbooks, so several
things are currently hard-coded:

* The hostname is hardcoded in several places as "kojidev.example.com".

* The main username is hardcoded in several places as "kdreyer".


Roles
-----

* ``roles/kdc`` - installs and configures a Kerberos KDC, and bootstraps all
  the keytabs we need.

  This will create a "kdreyer" Kerberos account. The ``koji-hub`` role will
  bootstrap this account into Koji's database. If you need more Kerberos
  users, add them here.

* ``roles/koji-ssl-admin`` - Creates the SSL CA and HTTPS keypair for the Koji
  server.

* ``roles/koji-client`` - Configures a ``kojidev`` script and `profile
  <https://docs.pagure.org/koji/profiles/>`_.

* ``roles/postgresql`` - installs and configures PostgreSQL for Koji Hub

* ``roles/koji-hub`` - installs and configures Koji Hub

  This role requires the `koji_host
  <https://github.com/ktdreyer/koji-ansible/blob/master/library/koji_host.py>`_
  module from the `koji-ansible project
  <https://github.com/ktdreyer/koji-ansible>`_.

  This role will bootstrap "kdreyer" as the first Koji administrator in the
  database.

  If you need more users, add them with the `koji_user
  <https://github.com/ktdreyer/koji-ansible/blob/master/library/koji_user.py>`_
  module.

* ``roles/koji-web`` - installs and configures the web interface for Koji.

* ``roles/koji-builder`` - installs and configures a Koji builder.

* ``roles/koji-ra`` - installs and configures the Koji "ra" (repository admin)
  service.

* ``roles/koji-gc`` - installs and configures the Koji garbage collector
  service.

* ``roles/activemq`` - installs and configures an ActiveMQ 5 broker for testing
  the Koji Hub protonmsg plugin.

* ``roles/rabbitmq`` - installs and configures a RabbitMQ broker for testing
  the Koji Hub protonmsg plugin.

See Also
--------

For managing resources within your Koji hub, please see the
https://github.com/ktdreyer/koji-ansible project.
