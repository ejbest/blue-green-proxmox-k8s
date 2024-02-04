### blue - green proxmox environment 
##### running VAULT, JENKINS, NGINX 

This is the instructions for booting the environemnt 
- maintaining 
- destroy
- deploy 

Technology 
- golang
- gitlab-ci
- terraform
- ansible 
- python 
- minio S3 api compatible with AWS S3 running here on prem
- HASHICORP vault 

#### deploy
1. cd ~/proxmox-kubernetes/docker/trigger_scripts
2. curl 192.168.0.97:2045/green-control-plane-vm-deploy?token=C05HZUAGH3L
3. check control-plane up ? need procedures (commands) and automated diag script?
4. curl 192.168.0.97:2045/green-worker-vm-deploy?token=C05HZUAGH3L
5. check worker up?  need procedures (commands) and automated diag script?
6. curl 192.168.0.97:2045/k8s-kubeadm-cluster-green-deploy?token=C05HZUAGH3L
7. check what in kubernetes? need procedures (commands) and automated diag script?
8. wait 6 minutes need procedures (commands) and automated diag script
8. curl 192.168.0.97:2045/k8s-kubeadm-workloads-green-deploy?token=C05HZUAGH3L
wait about 10 minutes ?
https://vault.advocatediablo.com
https://jenkins.advocatediablo.com
https://nextresearch.io



#### destory
1.  


#### deploy ci
1. curl 192.168.0.97:2045/green-ci-deploy
2. curl 192.168.0.97:2045/blue-ci-deploy

#### Workloads
1. curl 192.168.0.97:2045/green-workloads-deploy
2. curl 192.168.0.97:2045/blue-workloads-deploy

#### destroy ci
1. curl 192.168.0.97:2045/green-ci-destroy
1. curl 192.168.0.97:2045/blue-ci-destroy

#### backup 
#### sync



