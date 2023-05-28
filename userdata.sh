#!/bin/bash
    sudo yum update -y
    sudo yum install -y docker
    sudo systemctl start docker
    sudo usermod -aG docker ec2-user
    docker run -p 8080:80 nginx 
    
#user_ data is used to run linux commands to run in the instance after it has started. 
#Here we are instaling docker, starting docker service and then adding our user (ec2-user) 
#in a group called 'docker' (-aG stands for add in group). docker group is 
#automatially created when we install docker and has permission to run 
#all docker cmds. By adding our user in docker group, we won't need to 
#define sudo before every command.    