Refreshed devops2.0 toolkit repo to run builds with Ubuntu 16.04 xenial 64 images and some newer versions of software
===============================================================================

Prerequisits for host VM (for Ubuntu 16.04 host)
----------------------------------------------------------------------------------
install vagrant and some vagrant plugins 
```bash
vagrant plugin install vagrant-cachier
vagrant plugin install disksize
vagrant plugin install proxyconf
vagrant plugin install proxyconf
```

----------------------------------------------------------------------------------
Swarm Cluster deployed with Jenkins jobs
----------------------------------------------------------------------------------
start VM's for a cluster with cd (node for provision) swarm-master and two swarm worker nodes
```bash on host 
vagrant up cd swarm-master swarm-node-1 swarm-node-2
```
Connect to provision node
```bash
vagrant ssh cd
```
Start playbooks to proviosion swarm nodes and container with Jenkins master and slaves 
```bash on cd instance
ansible-playbook /vagrant/ansible/swarm.yml -i /vagrant/ansible/hosts/prod
ansible-playbook /vagrant/ansible/jenkins-node-swarm.yml -i /vagrant/ansible/hosts/prod
ansible-playbook /vagrant/ansible/jenkins.yml -c local
```
Checkout swarm cluster from provision node
```bash
export DOCKER_HOST=tcp://10.100.192.200:2375
docker info
```
Verify Jenkins console and jobs provisioned with playbooks above with link http://10.100.198.200:8080/job

----------------------------------------------------------------------------------
next chapter
----------------------------------------------------------------------------------