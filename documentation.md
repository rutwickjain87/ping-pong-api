# Introduction

The aim of this document is to explain the considerations made during the design of the API service, K8s cluster and the deployment workflow.

## Ping-Pong API Service

The API service is hosted here - https://github.com/rutwickjain87/ping-pong-api. It is forked from - https://github.com/alexwalling/ping-pong-api

**Note:** Some packages and dependencies were updated to newer versions in order for "npm ci" to be executed successfully.

To dockerize the API service, a Dockerfile has been created with below considerations:
- To ensure minimum size, a slim image of the official node docker image has been used. Use of 'Alpine' images is avoided for performance and security reasons
- multi-stage setup as one might require to use NPM TOKEN during build phase in order to access private NPM packages during "npm ci" . Hence, to avoid secret leakage in the image
- NODE_ENV set to 'production' for optimizing cache and overall performance
- "dumb-init" supervisor is used safely terminate nodejs service
- non-root user - "node" to run the nodejs service with restrictive permissions

## K8s Cluster

You can deploy the Nodejs deployment scripts on a local Kubernetes cluster using Minikube or Docker Desktop. It would spin up a single node K8s cluster where you can deploy and access the nodejs service.

You can find the installation instructions for Minikube and Docker Desktop here - 
1) Minikube - https://minikube.sigs.k8s.io/docs/start/
2) Docker Desktop - https://www.docker.com/products/docker-desktop/

However, you may choose any Cloud provider to provision and configure your Kubernetes cluster and run the kubernetes deployment scripts in order to deploy and access the nodejs service.

In case of Google Kubenetes Engine which runs on Google Cloud Platform, please follow below steps:

I created a sample Github repo with minimal terraform scripts to provision and configure a test Kubernetes Cluster.

Github: https://github.com/rutwickjain87/terraform-gke

### Pre-requisites for GKE:

1. Create a GCP account - https://cloud.google.com/

Once you have a GCP account created, you can create the Kubenetes cluster either using the GCP Console or using gCloud CLI. In order to use CLI, we need to install the Google Cloud SDK

2. Install Google Cloud SDK - https://cloud.google.com/sdk/docs/install-sdk

Please execute below steps once gcloud SDK is installed and configured on your local machine.
```
    glcoud init
    gcloud auth application-default login
```

3. Compute Engine API and Kubernetes Engine API are required for Terraform automation to work on this configuration. So, enable both APIs for your Google Cloud project before continuing.
```
    gcloud services enable compute.googleapis.com
    gcloud services enable container.googleapis.com
```
    
4. Install gke auth plugin to let `kubectl` authorize to GKE
 ```
    gcloud components install gke-gcloud-auth-plugin
 ```


### Provision GKE cluster using Terraform

Please execute the below steps in the given order to successfully provision and configure Kubernetes cluster

```
  terraform init
  terraform fmt -recursive
  terraform validate
  gcloud config get-value project
  terraform plan
  terraform apply
```
Upon successfully execution, a kubeconfig file will be generated at the base of the repo. Use that config file to access your K8s cluster.

```
  export KUBECONFIG=<path to the generated kubeconfig file>
```

## K8s Deployment Manifests

The Nodejs service can be deployed on Kubernetes using:
- A 'Deployment' resource to run the Nodejs service
- A 'Service' resource to access/expose the API endpoints of the Nodejs service

Optionally, an Ingress resource should be created if the deployment is carried out on a remote Kubernetes cluster, either in Cloud or on-Prem.

Below considerations are carried out while writing out the 'deployment' manifests:
- set liveness probe and readiness probe
- appropriate security context has been set:
    - run the pod as non-root user
    - readonly file system access
    - privilege escalation is denied
    - all Linux capabilities have been dropped
- pod anti-affinity can be configured optionally to run each replica on a different node whereever and whenever possible
- set resource limit and requests 

## Futher Improvements:

I have designed the setup to be minimal to demonstrate a functional workflow. However, for production-grade, there are quite a few things
that should be considered to achieve scalability, fault-tolerance, highly available and cost-effectiveness.

Some of the things that can be considered are:
- CICD workflow setup to build and push the docker image to registry of your choice
- Perform security scan for the API docker image to detect and fix any security vulnerabilities
- multinode K8s cluster in order to scheduled the pods on more than 1 node
- Enable Cluster Autoscaler for K8s cluster
- Enable Horizontal Pod Autoscaler(HPA) for the API service to scale-in/scale-out depending of metrics such RPS,CPU,Memory and others
- Use K8s NetworkPolicy to regulate pod incoming/outgoing traffic at the network level
- Implement Automate Backup & Restore of the K8s cluster
- Use ArgoCD tool to adopt GitOps model to deploy services to K8s
- Integrate Terraform with Atlantis for effective automation following GitOps model
- Logging and Monitoring at both, application and infrastructure level
