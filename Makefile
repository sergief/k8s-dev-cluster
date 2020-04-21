profile = k8s-dev-cluster

start:
	minikube start --memory 5120 --cpus 2 --profile $(profile) --driver=virtualbox
	minikube --profile $(profile) addons enable ingress

stop:
	minikube --profile $(profile) stop

dashboard:
	minikube --profile $(profile) dashboard

ip:
	minikube --profile $(profile) ip

install_jenkins:
	kubectl apply -f ./volumes/jenkins-volume.yml
	kubectl apply -f ./volumes/jenkins-volume-claim.yml
	kubectl apply -f ./deployments/jenkins-deployment.yml
	kubectl apply -f ./services/jenkins-service.yml
	kubectl apply -f ./controllers/jenkins-ingress.yml
	- kubectl create clusterrolebinding permissive-binding --clusterrole=cluster-admin --user=admin --user=kubelet --group=system:serviceaccounts

install_nexus:
		kubectl apply -f ./volumes/nexus-volume.yml
		kubectl apply -f ./volumes/nexus-volume-claim.yml
		kubectl apply -f ./deployments/nexus-deployment.yml
		kubectl apply -f ./services/nexus-service.yml
		kubectl apply -f ./controllers/nexus-ingress.yml

install_sonar:
		kubectl apply -f ./volumes/sonar-volume.yml
		kubectl apply -f ./volumes/sonar-volume-claim.yml
		kubectl apply -f ./deployments/sonar-deployment.yml
		kubectl apply -f ./services/sonar-service.yml
		kubectl apply -f ./controllers/sonar-ingress.yml

clean_jenkins:
	- kubectl delete deployments jenkins-deployment
	- kubectl delete services jenkins-service
	- kubectl delete -f controllers/jenkins-ingress.yml
	- kubectl delete persistentVolumeClaims jenkins-volume-claim
	- kubectl delete persistentVolumes jenkins-volume

clean_nexus:
	- kubectl delete deployments nexus-deployment
	- kubectl delete services nexus-service
	- kubectl delete -f controllers/nexus-ingress.yml
	- kubectl delete persistentVolumeClaims nexus-volume-claim
	- kubectl delete persistentVolumes nexus-volume

clean_sonar:
	- kubectl delete deployments sonar-deployment
	- kubectl delete services sonar-service
	- kubectl delete -f controllers/sonar-ingress.yml
	- kubectl delete persistentVolumeClaims sonar-volume-claim
	- kubectl delete persistentVolumes sonar-volume

install: install_jenkins install_nexus install_sonar

clean: clean_jenkins clean_nexus clean_sonar

ngrok_proxy:
	ngrok start --config ~/.ngrok2/ngrok.yml --config ./ngrok/config.yml githubWebhooks

.PHONY: install clean start dashboard ip stop install_jenkins clean_jenkins ngrok_proxy install_nexus clean_nexus install_sonar clean_sonar
