# InterSystems IRIS FHIR on AWS with EKS

This repository provides notes that accompany a Global Summit 2023 presentation on using the InterSystems IRIS FHIR server in AWS EKS.  These are intended as an accompanyment to the presentation.

You might be tempted to look at this and say "this is too long." Don't give up.  Just take it one step at a time and you'll do well.

## Pre-Requisites

You'll need to have a few clients installed on your machine:

* `eksctl`:  A command-line tool to simplify creating Kubernetes clusters in AWS EKS. (This happens to also install kubectl and the aws cli)  https://eksctl.io/
* `kubectl`: The standard command-line interface to Kubernetes
* `AWS CLI`: The standard command-line interface to AWS
* `helm`: The kubernetes appliation installation and management tool

You'll also need a `Hosted Zone` from AWS Route 53.


## Create a kubernets cluster

Follow the instructions in [eksctl/README.md](eksctl/README.md)

## external-dns - Manage the DNS entries automatically

Follow the instructions in [externaldns/README.md](externaldns/README.md)

## cert-manager - Manage SSL certificates automatically

Follow the instructions in [cert-manager/README.md](cert-manager/README.md)

## Install IKO

Follow the instructions in [iko/README.md](iko/README.md)

# Configure and Install k8s applications

Follow the instructions in [fhir-server/README.md](fhir-server/README.md)
