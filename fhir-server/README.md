# Create and Configure a FHIR Server

Let's set up a basic IRIS cluster in Kubernetes

*Pre-req* This assumes that you already have an InterSystems Container Registry (ICR) account & credentials and have installed IKO


## Overview

Our application consists of the following components (from inside out)

- InterSystems IRIS for Health with a FHIR server running
- IRIS Web Gateway to manage the FHIR web traffic
- Kubernetes service to expose the web gateway via an AWS Network Load Balancer
- DNS Entry for the NLB
- SSL keys to secure everything

## Create a Kubernetes Secret with your InterSystems Container Registry credentials

(You can skip this step if you're using the IRIS Community Edition)

We'll need to download the IRIS container from ICR, which means we need credentials installed in Kubernetes.  The username and password used here are the same as when you installed IKO, but we'll install the secret in the default namespace and name it slightly differently.

```
kubectl create secret docker-registry icr-secret --docker-server=https://containers.intersystems.com/v2/ --docker-username <YOUR USERNAME> --docker-password='<YOUR PASSWORD>' --docker-email=<YOUR EMAIL>
```

## Create a secret with your IRIS license key

(You can skip this step if you're using the IRIS Community Edition)

IRIS requires a valid license key, so let's take the license key and add it to Kubernetes so we can use it in our IRIS cluster.  Note:  The file *must* be named `iris.key`.

```
kubectl create secret generic fhir-iris-key-secret --from-file=iris.key
```

## Create a configmap with your IRIS CPF and CSP-merge.ini files

InterSystems uses CPF programatically configure IRIS.  There is extensive documentation on everything you can do with the CPF files.  The `common.cpf` file contains CPF parameters that are applied to all IRIS instances in the _IrisCluster_.  

1. Create a password hash for your IRIS by running the following
```
echo "MySecretPassword" | docker run -i containers.intersystems.com/intersystems/passwordhash:1.1
```

2. Edit the included example `common.cpf` file to include the password hash you just created

3. The `CSP-merge.ini` file contains changes to be applied to the web gateway configuration.  There is also extensive documentation on `CSP.ini`.  The example file sets the password for the CSPSystem web gateway administrator as well as the IRIS system password that's used to connect to IRIS.  These can only be created by setting them in the WebGateway UI on a test system and then copying them from the CSP.ini file on the test system.

Create the configmap
```
kubectl create cm fhir-cpf --from-file common.cpf --from-file CSP-merge.ini
```

## Create the Service

Let's start by creating the Network Load Balancer and the DNS entry.  The DNS entry is needed to create the SSL key, which we need to properly start IRIS.

```
kubectl apply -f service.yaml
```

## SSL Keys

We're going to need the SSL certificate to secure connections from your client to the web gateway, so let's create it.  You'll want to edit the `certificate.yaml` with your hostname.

```
kubectl apply -f certificate.yaml
```

cert-manager will be notified of the Certificate resource being created and will work with Let's Encrypt to create a TLS certificate which will be stored in the `fhir-tls-tls` Secret.

We also need an internal key for use between the web gateway and the IRIS superserver.  Let's create a basic self-signed key and then create a secret with it.

```
sh create-key.sh
kubectl create secret generic fhir-tls-internal-tls --from-file=ca.pem --from-file=tls.key --from-file=tls.crt
```

## Install IRIS + WebGateway

The IRIS Kubernetes Operator can deploy enterprise IRIS installations via a series of kubernetes resources.

Let's create a cluster
```
kubectl apply -f irisCluster.yaml
```

That creates the IRIS cluster and the web gateway.

## Create the FHIR Server

Once the IRIS cluster has been deployed, we can start the FHIR server on the iris instance.

Let's start an iris terminal session on the data server

```
kubectl exec -it fhir-tls-data-0 -- iris session iris
```

This will run an iris session in your container.  In that IRIS shell, you can create the FHIR server:

```
    Set $namespace = "HSLIB"

    Set appKey = "/csp/healthshare/demo/fhir/r4"
    Set strategyClass = "HS.FHIRServer.Storage.Json.InteractionsStrategy"
    Set metadataPackages = $lb("hl7.fhir.r4.core@4.0.1","hl7.fhir.us.core@3.1.0")

    ; Install a Foundation namespace and change to it
    Do ##class(HS.HC.Util.Installer).InstallFoundation("FHIR")
    Set $namespace = "FHIR"

    ; Install elements that are required for a FHIR-enabled namespace
    Do ##class(HS.FHIRServer.Installer).InstallNamespace()

    ; Install an instance of a FHIR Service into the current namespace
    Do ##class(HS.FHIRServer.Installer).InstallInstance(appKey, strategyClass, metadataPackages)
```

## Configure OAuth2

1. Create the OAuth2 Server
2. Create the Resource Client
3. Create an application Client (postman)


## Testing

Now that everything's set up, we can being using the IRIS instance. 

https://fhir.summit.cloudintersystems.com/csp/sys/UtilHome.csp


## Further Reading
* https://docs.intersystems.com/components/csp/docbook/DocBook.UI.Page.cls?KEY=AIKO#AIKO_clusterdef_configSource_csp
