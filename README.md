My tryouts to refresh "Devops 2.0 toolkit" book repository to make things work again:
===============================================================================
- updated image used in book tutorials from ubuntu/trusty64 to ubuntu/xenial64;
- changed some deprecated software packages versions were it was possible;
- changed some stuff in Ansible playbooks, considering things mentioned above;

Prerequisits for host VM (for Ubuntu 16.04 host)
----------------------------------------------------------------------------------
install vagrant and some vagrant plugins 
```
vagrant plugin install vagrant-cachier
vagrant plugin install disksize
vagrant plugin install proxyconf
vagrant plugin install proxyconf
```

Clone my repositories from github and navigate to a working directory
```
git clone https://github.com/awsivbilinskyy/myms-lifecycle.git
cd myms-lifecycle
```

----------------------------------------------------------------------------------
Automating Blue-Green Deployment
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
Swarm Cluster Blue-Green deployment with Jenkins jobs
----------------------------------------------------------------------------------
Clone repository from github
```
git clone https://github.com/awsivbilinskyy/myms-lifecycle.git
cd myms-lifecycle
```
Start VM's for a cluster with cd (node for provision) swarm-master and two swarm worker nodes
```
vagrant up cd swarm-master swarm-node-1 swarm-node-2
```
Connect to provision node
```
vagrant ssh cd
```
Start playbooks to proviosion swarm nodes and container with Jenkins master and slaves 
```
ansible-playbook /vagrant/ansible/swarm.yml -i /vagrant/ansible/hosts/prod
ansible-playbook /vagrant/ansible/jenkins-node-swarm.yml -i /vagrant/ansible/hosts/prod
ansible-playbook /vagrant/ansible/jenkins.yml -c local
```
Checkout swarm cluster from provision node
```
export DOCKER_HOST=tcp://10.100.192.200:2375
docker info
```
Verify Jenkins console and jobs provisioned with playbooks above with link http://10.100.198.200:8080, launch the job "books-ms-swarm" (link on job http://10.100.198.200:8080/job/books-ms-swarm/ ) with "Scan Mutlibranch Pipeline Now" bottun to start the automatic deployment, the job does the next: 
- job creates an images of books-ms application;
- pulls image into local registry;
- deploys application on nodes of swarm cluster;

After succesful completition of the job, to verify application deployment from cd node, execute the follows:
```
docker ps -a --filter name=books --format "table {{.Names}}\t{{.Status}}"
```
which should return the next results:
```
NAMES                             STATUS
swarm-node-2/booksms_app-blue_1   Up 36 minutes
swarm-node-1/books-ms-db          Up 36 minutes
```
to verify the service of application itself run from bash:
``` 
curl 10.100.192.200:8500/v1/catalog/service/books-ms-blue | jq '.'
curl 10.100.192.200:8500/v1/kv/books-ms/color?raw
curl 10.100.192.200:8500/v1/kv/books-ms/instances?raw
```
or open in browser http://10.100.192.200:8500/v1/catalog/service/books-ms-blue. To verify registered services status in Consul ui http://10.100.192.200:8500/ui/#/dc1/services.

----------------------------------------------------------------------------------
Self-Healing Systems
----------------------------------------------------------------------------------


----------------------------------------------------------------------------------
next chapter
----------------------------------------------------------------------------------