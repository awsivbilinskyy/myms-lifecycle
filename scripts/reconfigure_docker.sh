#!/bin/bash
echo -e "Docker service previos config ============================================= \n$(sudo cat /etc/systemd/system/docker.service | grep ExecStart)"
sudo sed -i 's/ExecStart=\/usr\/bin\/dockerd -H fd:\/\//ExecStart=\/usr\/bin\/dockerd --insecure-registry 10.100.198.200:5000 --registry-mirror=http:\/\/10.100.198.200:5001 -H unix:\/\/\/var\/run\/docker.sock -H fd:\/\//g' /etc/systemd/system/docker.service
sudo sed -i 's/EnvironmentFile=-\/etc\/default\/docker/Environment=DOCKER_API_VERSION=1.24/g' /etc/systemd/system/docker.service
sudo systemctl daemon-reload
sudo systemctl restart docker
echo -e "Docker service new config ============================================= \n$(sudo cat /etc/systemd/system/docker.service | grep ExecStart)"