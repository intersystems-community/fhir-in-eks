# Installing and Configuring External DNS

external-dns is a kubernetes application that creates and manages DNS entries as requested by k8s resources like services and ingress.  Once installed, all you need to do add the right annotations to your resource and the corresponding DNS entry will be created.

*Pre-req* This assumes that you already created the external-dns AWS IAM Role and k8s ServiceAccount via eksctl.  It also assumes you have a Route 53 hostedZone.

## Install External DNS

1. Edit `externaldns-with-rbac.yaml` to set the AWS region name and domain-filter (you don't want to use summit.cloudintersystems.com)

2. Deploy

```
kubectl create --filename externaldns-with-rbac.yaml -n kube-system
```

## What does it do?

External DNS monitors the Kubernetes API for resources (services or ingress) with the `external-dns.alpha.kubernetes.io/hostname` annotation.  When one is created, it creates the corresponding DNS entry.

```
metadata:
  name: external-iris-fhir-iam
  annotations:
    external-dns.alpha.kubernetes.io/hostname: fhir.summit.cloudintersystems.com
```

## More Reading:
* https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/aws.md
* https://aws.amazon.com/premiumsupport/knowledge-center/create-subdomain-route-53/
