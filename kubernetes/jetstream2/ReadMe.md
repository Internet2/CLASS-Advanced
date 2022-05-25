# Kubernetes on Jetstream2

This is a proof of concept demonstration of Kubernetes on Jetstream2 and is only lightly tested.  It is designed to be easily deployed by individuals with a minimum of tooling and runs as a single `cloud-init` script may run in other cloud or bare-metal environments.

## Prerequisites
  1. A Jetstream2 account is needed (https://jetstream-cloud.org/).
  2. IPIP traffic must be allowed. To enable it do the following:
     * Navigate to the Security Groups setting (https://js2.jetstream-cloud.org/project/security_groups/)
     * For the "exosphere" rule click "Manage Rules"
     * Click "Add Rule" and in the dialog box
       * In "Rule*" select "Other Protocol"
       * For "Description" enter "Internal IPIP"
       * For "Direction" leave as "Ingress"
       * For "IP Protocol" enter "4" (without the quotes)
       * For "Remote" leave as "CIDR"
       * For "CIDR" enter "10.0.0.0/8" (without the quotes)
       * Review settings and click "Add"
  3. Upload a SSH key (out of scope).  This can be done now or when creating the controller node in Exosphere.

## Provision Kubernetes

You need to create a controller node and multiple compute nodes. To create a VM in Exosphere (https://jetstream2.exosphere.app/exosphere) select the Allocation you wish to use and click the red "Create" button then "New Instance" and select "Rocky Linux 8".  Other distributions, including Ubuntu *should* also work but are untested.

To create the controller node (create only one) create a new VM (see previous paragraph) and change the following options and then click "Create" at the bottom.
  * Flavor: Select `m3.small` or larger
  * Advanced Options: Select "Show"
  * SSH Public Key: Select the desired key or "Upload a new SSH Key" if you have not already setup your ssh key.
  * Boot Script: replace the entire text with the contents of the `cloud-init-controller.yaml` file (copy/paste)

 Once the VM is in the "Ready" state you will need to find the "join command" to allow compute nodes to connect to the controller.  To do this do the following:
  * Find the IP address ($IP) of the controller VM in the web interface.
  * Use a local ssh client to connect to the VM as root (`ssh root@$IP`).
  * Run `cat join.sh` on the VM to show the join command.

You will use the "join command" in the next step and it should look like the following:
```
kubeadm join 10.0.65.100:6443 --token abcdef.aaaa0bbbb1abcdef --discovery-token-ca-cert-hash sha256:2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824
```

You will now need to create additional compute nodes (Instances) making the following changes (please note the differences):
  * Flavor: Select `m3.small` or larger
  * How many Instance: Select the number of compute nodes (3 is a good number to start with)
  * Advanced Options: Select "Show"
  * Public IP Address: Select "Do not create or assign a public IP" if desired (not required)
  * SSH Public Key: Select your ssh key
  * Boot Script: 
    * Replace the entire text with the contents of the `cloud-init-controller.yaml` file (copy/paste)
    * Replace the line near the botom with `# replace with join` with the join command preceded with `- ` using the same indentation (see example below).

```
  - /var/lib/cloud/scripts/per-once/10-k8-config.sh
  - kubeadm join 10.0.65.100:6443 --token abcdef.aaaa0bbbb1abcdef --discovery-token-ca-cert-hash sha256:2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824
```

After clicking "Create" wait for the compute nodes to enter the "Ready" state and ssh into the controller node as root.  After a few minutes for the compute nodes to join you should have a basic working Kubernetes cluster.  You may wish to run `k9s` on the controller to monitor the cluster.

## Using Kubernetes
Using the cluster is out side the scope of this documents, please note the following:
  * The admin `config` file is stored in `/root/.kube/config`.
  * To use the `config` file outside the cluster you must edit the file and change the URL from the internal IP to the external/public ip.
  * Utility `k9s` is installed to interact with the cluster.

## Advanced Notes
  * This should run on modern Deb and RPM based systems.
  * This should work using the Openstack interface or the CLI.
  * This should also run on other clouds that support `cloud-init`
  * Kubernetes uses networks 10.80.0.0/16 and 10.96.0.0/12.
  * Calico is installed as an operator and must use IPIP all the time since openstack filters packets and IPIP traffic (protocol 4) must be enabled (denied by default).  For other systems, see the documentation on configuration options (https://projectcalico.docs.tigera.io/reference/installation/api) used in the created `custom-resources.yaml` file during setup.
  * The CRI used is `containerd`, not Docker.
  * SSH Passwords are turned off and root is allowed.  SSH keys are inserted by Jetstream.
  * The join token is in plain-text in the `cloud-init` script.
  * The default Jetstream user "exouser" is not created.
