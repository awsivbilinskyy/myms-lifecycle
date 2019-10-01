My tryouts to refresh "Devops 2.0 toolkit" book repository to make things work again:
===============================================================================
- updated image used in book tutorials from ubuntu/trusty64 to ubuntu/xenial64;
- changed some deprecated versions of software packages were it was possible;
- changed some stuff in Ansible playbooks, considering things mentioned above;
- changed some features in Jenkins pipelines (some original jobs)

Prerequisits for host VM (for Ubuntu 16.04 host)
----------------------------------------------------------------------------------
install vagrant and some vagrant plugins:
```
vagrant plugin install vagrant-cachier
vagrant plugin install disksize
vagrant plugin install proxyconf
vagrant plugin install proxyconf
```

Clone my repositories from github and navigate to a working directory:
```
git clone https://github.com/awsivbilinskyy/myms-lifecycle.git
cd myms-lifecycle
```

----------------------------------------------------------------------------------
Automating Blue-Green Deployment 
----------------------------------------------------------------------------------
(Book Chapter: "")

----------------------------------------------------------------------------------
Swarm Cluster Blue-Green deployment with Jenkins jobs (verified)
----------------------------------------------------------------------------------
(Book Chapter: "Clustering And Scaling Services: Automating Deployment With Docker Swarm and Ansible", page 291)

Start VM's for a cluster with cd (node for provision) swarm-master and two swarm worker nodes
```
vagrant up cd swarm-master swarm-node-1 swarm-node-2
```
Connect to provision node
```
vagrant ssh cd
```
Start playbooks to provision swarm nodes and container with Jenkins master and slaves 
```
ansible-playbook /vagrant/ansible/swarm.yml -i /vagrant/ansible/hosts/prod
ansible-playbook /vagrant/ansible/jenkins-node-swarm.yml -i /vagrant/ansible/hosts/prod
ansible-playbook /vagrant/ansible/jenkins.yml -c local
```
Open Jenkins console and launch the job "books-ms-swarm" (link on job http://10.100.198.200:8080/job/books-ms-swarm/ ) with "Scan Mutlibranch Pipeline Now" bottun to start the Blue deployment.
After succesful completition of the job, to checkout swarm cluster and application deployment from cd node, execute the follows:
```
export DOCKER_HOST=tcp://10.100.192.200:2375
docker info
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

Send data to application 
```
curl -H 'Content-Type: application/json' -X PUT -d \
'{"_id": 1,
"title": "My First Book",
"author": "John Doe",
"description": "Not a very good book"}' \
10.100.192.200/api/v1/books | jq '.' && \
curl -H 'Content-Type: application/json' -X PUT -d \
'{"_id": 2,
"title": "My Second Book",
"author": "John Doe",
"description": "This one better"}' \
10.100.192.200/api/v1/books | jq '.'
```
verify the data were successfuly saved by URL http://10.100.192.200/api/v1/books or by shell:
```
curl 10.100.192.200/api/v1/books | jq '.'
```
Run Jenkins job "books-ms-swarm" http://10.100.198.200:8080/job/books-ms-swarm/ once more to get Green Deployment and after completition verify the result:
```
docker ps -a --filter name=books --format "table {{.Names}}\t{{.Status}}" && \
curl 10.100.192.200/api/v1/books | jq '.'
```
should return:
```
NAMES                              STATUS
swarm-node-1/booksms_app-green_1   Up 56 minutes
swarm-node-2/booksms_app-blue_1    Exited (137) 55 minutes ago
swarm-node-1/books-ms-db           Up 2 hours

[
  {
    "_id": 1,
    "title": "My First Book",
    "author": "John Doe"
  },
  {
    "_id": 2,
    "title": "My Second Book",
    "author": "John Doe"
  }
]
```
with Green deployment running, while Blue exited, with the data we've inputed for Blue deployment.

For cleaning up the environment exit the cd VM, and use cleanup.sh script.

----------------------------------------------------------------------------------
Self-Healing Systems (verified)
----------------------------------------------------------------------------------
(Book Chapter: "Self-Healing Systems: Self-healing with Docker, ConsulWatches, and Jenkins", page 312)

Start VM's for a cluster with cd (node for provision) swarm-master and two swarm worker nodes
```
vagrant up cd swarm-master swarm-node-1 swarm-node-2
```
Connect to provision node
```
vagrant ssh cd
```
Start playbooks to provision swarm nodes Jenkins master and slaves for service healing
```
ansible-playbook /vagrant/ansible/swarm.yml -i /vagrant/ansible/hosts/prod

ansible-playbook /vagrant/ansible/jenkins-node-swarm.yml -i /vagrant/ansible/hosts/prod

ansible-playbook /vagrant/ansible/jenkins.yml --extra-vars "main_job_src=service-healing-config.xml" -c local

ansible-playbook /vagrant/ansible/swarm-healing.yml -i /vagrant/ansible/hosts/prod
```
Open http://10.100.192.200:8500/ui/#/dc1/nodes/swarm-master to verify the new checks were created.

Start the job to deploy the books-ms application with health self-checks http://10.100.198.200:8080/job/books-ms/ 

To verify the results of job execution through Consul follow the link http://10.100.192.200:8500/ui/#/dc1/services/books-ms

Connect to swarm-master node and stop nginx container which will cause books-ms application to fail, which will triger the redeployment job to fix application state
```
exit;

vagrant ssh swarm-master

docker stop nginx

exit;

vagrant ssh cd

curl 10.100.192.200/api/v1/books
```
after few minutes check the output of redeployment job which was triggered when books-ms application failed one of the checks
http://10.100.198.200:8080/job/service-redeploy/lastBuild/console
and check from the console 
```
curl -I 10.100.192.200/api/v1/books

export DOCKER_HOST=tcp://10.100.192.200:2375

docker rm -f $(docker ps --filter name=booksms --format "{{.ID}}")
```

----------------------------------------------------------------------------------
next chapter
----------------------------------------------------------------------------------
(Book Chapter: "")