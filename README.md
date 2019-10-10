My tryouts to refresh "Devops 2.0 toolkit" book repository to make things work again:
===============================================================================
- updated image used in book tutorials from ubuntu/trusty64 to ubuntu/xenial64;
- changed some deprecated versions of software packages were it was possible;
- changed some stuff in Ansible playbooks, considering things mentioned above;
- changed some features in Jenkins pipelines (some original jobs)

 NOTE:
* I've tried to fix the issues I faced myself passing the book chapters covering CI/CD automation, deployments, self-healing, and system monitoring, so the best way is to go through the book chapters mentioned above along with a code from this repo. However, some of my solutions are not the best so you are free to find the better suitable for you.

Prerequisits for host VM
----------------------------------------------------------------------------------
for Ubuntu (16.04/18.04) host:

* Installation of Oracle Virtual Box and Vagrant are required on host machine:
```
sudo apt-get install -y virtualbox

sudo apt-get install -y vagrant
```
* verify Vagrant installation and install additional vagrant plugins on host:
```
vagrant -v

vagrant plugin install vagrant-cachier && \
vagrant plugin install disksize && \
vagrant plugin install proxyconf
```

* Clone my repositories from github and navigate to a working directory:
```
git clone https://github.com/awsivbilinskyy/mybooks-ms.git 

git clone https://github.com/awsivbilinskyy/myms-lifecycle.git

cd myms-lifecycle
```

----------------------------------------------------------------------------------
previous chapters 
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
Automating Implementation of the Deployment Pipeline (verify)
----------------------------------------------------------------------------------
(Book Chapter: "Automating Implementation of theDeployment Pipeline", page 178)

Start VM's for needed for this book chapter and connect to cd node:
```
vagrant up cd prod

vagrant ssh cd
```
clone application repository on cd node and enter working directory:
```
git clone https://github.com/awsivbilinskyy/mybooks-ms.git

cd mybooks-ms
```
now we will run Ansible playbook to deploy all provision steps described in book chapter 
```
ansible-playbook /vagrant/ansible/service.yml -i /vagrant/ansible/hosts/prod --extra-vars "repo_dir=$PWD service_name=books-ms"
```
* notice: from time to time this may fail with an error:
"Failed to import the required Python library (Docker SDK for Python: docker (Python >= 2.7) or docker-py (Python 2.6)" - to fix this just restart the playbook once more

to verify if application was deployed succesfuly the next command:
```
curl -i http://10.100.198.201/api/v1/books
```
should return "HTTP/1.1 200 OK..." responce

----------------------------------------------------------------------------------
Continuous Integration (CI), Delivery and Deployment (CD) Tools
----------------------------------------------------------------------------------
(Book Chapter: "Continuous Integration (CI), Delivery and Deployment (CD) Tools: Jenkins", page 196)

Start VM's for Jenkins setup and connect to cd node:
```
vagrant up cd prod

vagrant ssh cd
```
setup and configure Jenkins node and master nodes:
```
ansible-playbook /vagrant/ansible/jenkins-node.yml -i /vagrant/ansible/hosts/prod
ansible-playbook /vagrant/ansible/jenkins.yml -c local
```
launch Jenkins job to provision prod node with ansible http://10.100.198.200:8080/job/books-ms-ansible/

* notice from time to time this may fail with an error:
"Failed to import the required Python library (Docker SDK for Python: docker (Python >= 2.7) or docker-py (Python 2.6)" - to fix this just restart the playbook once more

To start the parameterized job for service deployment follow the link http://10.100.198.200:8080/job/books-ms/ 
with default parameters

to verify service in Consul  http://10.100.198.201:8500/ui/#/dc1/services/books-ms

to verify service from console, connect to prod node and run curl command:
```
vagrant ssh prod

curl -i http://10.100.198.201/api/v1/books
```
should return "HTTP/1.1 200 OK ...."


----------------------------------------------------------------------------------
Automating Blue-Green Deployment
----------------------------------------------------------------------------------
(Book Chapter: "Blue-Green Deployment: Automating the Blue-Green Deployment with Jenkins Workflow", page 244)

Start VM's for Blue-Green Deployment and connect to cd node:
```
vagrant up cd prod

vagrant ssh cd
```
run playbooks to provision all that will be needed for Blue-Green deployment:
```
ansible-playbook /vagrant/ansible/prod2.yml -i /vagrant/ansible/hosts/prod

ansible-playbook /vagrant/ansible/jenkins-node.yml -i /vagrant/ansible/hosts/prod 

ansible-playbook /vagrant/ansible/jenkins.yml -c local
```
* notice: from time to time this may fail with an error:
"Failed to import the required Python library (Docker SDK for Python: docker (Python >= 2.7) or docker-py (Python 2.6)" - to fix this just restart the playbook once more

open Jenkins job http://10.100.198.200:8080/job/books-ms-blue-green/ ,click the "Scan Multi-branch Pipeline Now" link for running automated blue-green deployment.
At the first run it will deploy blue release. To verify what release is actually deployed from cd node execute the next: 
```
export DOCKER_HOST=tcp://10.100.198.201:2375

docker ps -a --filter name=books --format "table {{.Names}}"
```
to verify this from console run:
```
curl 10.100.198.201:8500/v1/catalog/services | jq '.'

curl 10.100.198.201:8500/v1/catalog/service/books-ms-blue | jq '.'

curl -I 10.100.198.201/api/v1/books
```
or you can verify current color of release deployed from Consul ui http://10.100.198.201:8500/ui/#/dc1/kv/books-ms/color/edit

----------------------------------------------------------------------------------
Swarm Cluster Blue-Green deployment with Jenkins jobs
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
Self-Healing Systems - redeployment, scaling, descaling jobs
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
### on cd node ###

ansible-playbook /vagrant/ansible/swarm.yml -i /vagrant/ansible/hosts/prod

ansible-playbook /vagrant/ansible/jenkins-node-swarm.yml -i /vagrant/ansible/hosts/prod

ansible-playbook /vagrant/ansible/jenkins.yml --extra-vars "main_job_src=service-healing-config.xml" -c local

ansible-playbook /vagrant/ansible/swarm-healing.yml -i /vagrant/ansible/hosts/prod

exit;
```
Open http://10.100.192.200:8500/ui/#/dc1/nodes/swarm-master to verify the new checks were created.

Start the job to deploy the books-ms application with health self-checks http://10.100.198.200:8080/job/books-ms/ 

To verify the results of job execution through Consul follow the link http://10.100.192.200:8500/ui/#/dc1/services/books-ms

Connect to swarm-master node and stop nginx container which will cause books-ms application to fail, which will triger the redeployment job to fix application state
```
vagrant ssh swarm-master

### on swarm-master node 

docker stop nginx

exit;

### back to cd node

vagrant ssh cd

curl 10.100.192.200/api/v1/books
```
after few minutes check the output of redeployment job which was triggered when books-ms application failed one of the checks
http://10.100.198.200:8080/job/service-redeploy/lastBuild/console
when service-redoploy job and has finished check application status from cd node :
```
curl -I 10.100.192.200/api/v1/books
```

Now we triggered the same job but for the case when container with application is completely removed, run from cd node:  
```
export DOCKER_HOST=tcp://10.100.192.200:2375

docker rm -f $(docker ps --filter name=booksms --format "{{.ID}}")
```
after few minutes check http://10.100.198.200:8080/job/service-redeploy/lastBuild/console, the job redeployed application, to verify this from the console:
```
docker ps --filter name=books --format "table {{.Names}}"

curl -I swarm-master/api/v1/books
```
should return HTTP responce 200 

For scaling application run http://10.100.198.200:8080/job/books-ms-scale/ parametrised job with desired scale count set as paramter (default 2). This will redeploy the service. To verify this run the next:
```
export DOCKER_HOST=tcp://10.100.192.200:2375

docker ps --filter name=books --format "table {{.Names}}"

curl 10.100.192.200:8500/v1/kv/books-ms/instances?raw
```
For descaling application run http://10.100.198.200:8080/job/books-ms-descale parametrised job with desired count of instances (default -2). To verify this run the next:
```
docker ps --filter name=books --format "table {{.Names}}"

curl 10.100.192.200:8500/v1/kv/books-ms/instances?raw

exit;
```

----------------------------------------------------------------------------------
Centralized Logging and Monitoring (verified)
----------------------------------------------------------------------------------
(Book Chapter: "Centralized Logging and Monitoring: ", page 347)

Start environment VM's from host machine:
```
vagrant up cd prod logging
```

on cd node run the next playbook to provision monitoring toolset:
```
vagrant ssh cd

ansible-playbook /vagrant/ansible/elk.yml -i /vagrant/ansible/hosts/prod --extra-vars "logstash_config=file.conf"

exit;
```
* notice from time to time this may fail with an error:
"Failed to import the required Python library (Docker SDK for Python: docker (Python >= 2.7) or docker-py (Python 2.6)" - to fix this just restart the playbook once more

connect to logging node and fill in and checkout the entries for logstash :
```
vagrant ssh logging

echo "my first log entry" >/data/logstash/logs/my.log && \
echo "my second log entry" >>/data/logstash/logs/my.log && \
echo "my third log entry" >>/data/logstash/logs/my.log

docker logs logstash
```
and verify those events displayed in Kibana http://10.100.198.202:5601 (note: first time index "logstash-*" needs to be created).

copy sample apache log into logstash:
```
cat /tmp/apache.log >>/data/logstash/logs/apache.log

docker logs logstash
```

replace logstash conffile with filters
```
sudo cp /data/logstash/conf/file-with-filters.conf /data/logstash/conf/file.conf && \
docker restart logstash

cat /tmp/apache2.log >>/data/logstash/logs/apache.log && \
docker restart logstash
```

```
ansible-playbook /vagrant/ansible/elk.yml -i /vagrant/ansible/hosts/prod --extra-vars "logstash_config=beats.conf"

ansible-playbook /vagrant/ansible/prod3.yml -i /vagrant/ansible/hosts/prod

docker -H tcp://10.100.198.202:2375 logs logstash
```
ansible-playbook /vagrant/ansible/elk.yml -i /vagrant/ansible/hosts/prod --extra-vars "logstash_config=syslog.conf"

