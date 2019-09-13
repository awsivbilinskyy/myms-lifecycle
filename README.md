Refreshed devops2.0 toolkit repo to run builds with Ubuntu 16.04 xenial 64 
images and some newer versions of software
===============================================================================

prerequirments for host VM 
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
```bash on host 
vagrant up cd swarm-master swarm-node-1 swarm-node-2
vagrant ssh cd
```
```bash on cd instance
### run ansible playbooks on cluster VM's ###########################################
ansible-playbook /vagrant/ansible/swarm.yml -i /vagrant/ansible/hosts/prod
ansible-playbook /vagrant/ansible/jenkins-node-swarm.yml -i /vagrant/ansible/hosts/prod
ansible-playbook /vagrant/ansible/jenkins.yml -c local

### checkout swarm cluster ##########################################################
export DOCKER_HOST=tcp://10.100.192.200:2375
docker info

```

----------------------------------------------------------------------------------
Swarm Cluster deployed with Jenkins jobs
----------------------------------------------------------------------------------