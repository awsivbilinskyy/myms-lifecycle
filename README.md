Refreshed devops2.0 toolkit repo to run builds with Ubuntu 16.04 xenial 64 images and some newer versions of software
===============================================================================

Prerequisits for host VM (for Ubuntu 16.04 host)
----------------------------------------------------------------------------------
install vagrant and some vagrant plugins 
```
vagrant plugin install vagrant-cachier
vagrant plugin install disksize
vagrant plugin install proxyconf
vagrant plugin install proxyconf
```
----------------------------------------------------------------------------------
Automating Blue-Green Deployment
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
Swarm Cluster deployed with Jenkins jobs
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
- job creates an images of books-ms application
- pulls image into local registry
- deploys application on nodes of swarm cluster
After succesful completition of the job, to verify application deployment from cd node, run the next:
```
docker ps -a --filter name=books --format "table {{.Names}}\t{{.Status}}"
```
should return the next output, with booksms_app and books-ms-db containers running with status "Up":
```
NAMES                             STATUS
swarm-node-2/booksms_app-blue_1   Up 36 minutes
swarm-node-1/books-ms-db          Up 36 minutes
```
to verify the service of application itself run the next from bash:
``` 
curl 10.100.192.200:8500/v1/catalog/service/books-ms-blue | jq '.'
curl 10.100.192.200:8500/v1/kv/books-ms/color?raw
curl 10.100.192.200:8500/v1/kv/books-ms/instances?raw
```
or open the next link in browser http://10.100.192.200:8500/v1/catalog/service/books-ms-blue
Verify registered services status in Consul http://10.100.192.200:8500/ui/#/dc1/services

----------------------------------------------------------------------------------
Self-Healing Systems
----------------------------------------------------------------------------------


----------------------------------------------------------------------------------
next chapter
----------------------------------------------------------------------------------