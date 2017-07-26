# Building an OpenStack Cloud from Bare Metal

## Overview


## Prerequisites

For this lab, you'll need a desktop/laptop (Windows, Mac, or Linux) with an SSH client and a web browser.

You can download PuTTY, an SSH client for Windows at:

https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html

Install the Windows package since you'll need one of the PuTTY utilities (putty and puttygen).

## Bare Metal Service Account

For this workshop, you'll be using physical servers provided by Packet. Specifically, you'll be using one of their 'Type 1' servers, a 32 GB, 120GB x 2 SSD (RAID-1), 4 core Xeon server. Packet provides their servers by the hour. With code SDOPENSTACK, you'll get $25 of free credit. The 'Type 1' is $0.40/hour so the $25 credit will get you 62 hours of CPU use. Be sure to shut down the server at the end of the workshop!

Sign up at www.packet.net and use code SDOPENSTACK. You'll need to provide a credit card or PayPal account to get the $25 in free credit.

## Setting up 

If you are connecting from a Windows machine, you can use these instructions on how to generate SSH keys.

https://help.packet.net/quick-start/generate-ssh-keys

Make sure you upload your new key into your new Packet project before you start the server!

## Startup a Bare Metal Server

Packet has instructions on how to startup your first server. 

https://help.packet.net/quick-start/deploy-a-server

* If you have previously setup an account and SSH keys with packet.net you can skip to step #4 (deploy a server) from the deploy-a-server instructions.

After creating a project make sure to use the following settings for deploying the server

Hostname: Magnum

Project:  Your Project Name

Config:  Type I

OS:  CentOS 7

Location: Parisppany, NJ

Manage: Subnet Size->/28  Save & Contine

Deploy

It'll take about 8 minutes for the new server to start up.

Be sure to take note of the new server IP address.

## Log into the Bare Metal Server

Using PuTTY (Windows) or ssh (Mac/Linux), connect to the new bare metal, physical server that was deployed. Refer to step #5 in the Packet guide above if you need help. You'll be logging as as 'root' with no password required (SSH keys used instead of the password).

When connecting using PuTTY on Windows, use the following instructions to login using the SSH key generated above.

* Click Connection > Data in the left-hand navigation pane and set the Auto-login username to root.

* Click Connection > SSH > Auth in the left-hand navigation pane and configure the private key to use by clicking Browse under Private key file for authentication.

* Navigate to the location where you saved your private key earlier, select the file, and click Open.* 

## Download and Run Install Scripts

Once the you're logged in as root execute the following commands. This installs the underlying cloud and container orchestration engines (COE)

````
wget https://raw.githubusercontent.com/OpenStackSanDiego/magnum-container-cloud/master/setup.sh
sh setup.sh
more keystonerc_admin
````
Take note of the OS_USERNAME (admin) and OS_PASSWORD. You'll need these to log into the GUI.

Restart the system.

````
reboot
````

## Log into the Cloud GUI

Once everything has rebooted. Connect to the GUI at: http://YOUR_SERVER_IP/. Use the login admin with the OS_PASSWORD from above.

## Startup a Kubernetes Cluster

Create a new keypair called Magnum

* Project->Computer->Key Pairs->Create Key Pair
* Keypair Name: Magnum
* A magnum.pem file will be downloaded to your computer

Create a Kubernetes Cluster Template:

* Project->Container Infra->Cluster Templates>+ Create Cluster Templates
  
   __Info__    
  * Cluster Template Name: ````Kubernetes-Atomic````
  * Container Orchestration Engine: Kubernetes
  * Public: Checked
  * Disabled TLS: Checked
  
  __Node Spec__
   * Image: Fedora-Atomic-25
   * Keypair: Magnum
   
  __Network__
   * External Network ID: ````public```` (needs to be all lower case)
   * DNS: ````8.8.8.8````
   * Floating IP: Checked
 
 * Click submit

Create a Kubernetes Cluster based upon the template.

* Cluster Templates->Kubernetes-Atomic->Create Cluster
 
  __Info__
  * Cluster Name: ````Kubernetes-Atomic-Dev````
  
  __Size__
  * Master Count: 1
  * Node Count: 2
  
* Click Submit

Click through to the see the list of compute instances, network security groups, and networks created.

Log into the Kubernetes master node via SSH. Use the Magnum key created above.

## Startup a Docker Swarm Cluster

Repeat the steps above with a new template and cluster. Replace the COE with "Docker Swarm"

Click through to the see the list of compute instances, network security groups, and networks created.

Log into the Docker master node via SSH. Use the Magnum key created above.

Startup the basic Docker container to verify functionality (this required root access).

* sudo su -
* docker run helloworld


## Shutting it all down

From the Packet Application website, select the bare metal server and mark it for deletion.

You are welcome to keep the server running but remember that you will keep being charged until you delete it via the Packet web app.

