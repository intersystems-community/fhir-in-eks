# IKO - The InterSystems Kubernetes Operator

The InterSystems Kubernetes Operator is a Kubernetes Operator that extends the Kubernetes API to all you to manage IRIS instances via the `IrisCluster` resource type.

*Pre-req* This assumes that you already have an InterSystems Container Registry (ICR) account & credentials and have installed the `helm` command line program

## Create a Kubernetes Secret with your ICR credentials

We'll need to download the IKO container from ICR, which means we need credentials installed in Kubernetes.  Let's put everything for IKO in the `iko` namespace.

```
kubectl create namespace iko
kubectl create secret docker-registry -n iko dockerhub-secret --docker-server=https://containers.intersystems.com/v2/ --docker-username <YOUR USERNAME> --docker-password='<YOUR PASSWORD>' --docker-email=<YOUR EMAIL>
```

## Install IKO

For convienience, this directory includes a copy of the IKO 3.5 helm chart.  You may want to download the latest version from the WRC download site.

```
helm install intersystems chart/iris-operator -n iko
```

## Further Reading

* ICR Web UI: https://containers.intersystems.com/contents
* IKO Documentation: https://docs.intersystems.com/components/csp/docbook/DocBook.UI.Page.cls?KEY=PAGE_iko
