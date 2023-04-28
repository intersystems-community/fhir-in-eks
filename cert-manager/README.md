# Installing and Configuring cert-manager

cert-manager is a kubernetes application that creates and manages TLS keys that can be used for a wide variety of purposes - including, of course, HTTPS.  Creating and maintaining keys is as simple as managing any other kubernetes resource.

This demonstrates how to install cert-manager and configure certificate issuers for both internet-facing use and internal use.

*Pre-req* This assumes that you already created the external-dns IAM Role and k8s ServiceAccount via eksctl.  It also assumes you have a Route 53 hostedZone.

## Install cert-manager


Installing cert-manager is dead simple.  Just apply the YAML of version 1.11.0.

```
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.yaml
```

## Create a ClusterIssuer for public certificates

A ClusterIssuer is a cert-manager plug-in that issues certificates.  You can have multiple installed in your kubernetes cluster, each creating certificates in a different way.  

For this demo, we're using the most popular ClusterIssuer - Let's Encrypt.  Let's Encrypt has two types of _validators_ (how it knows you own the domain you say you own) - one based on DNS and one based on http.  I prefer the DNS validator since it doesn't require messing with your web server.

The DNS issuer needs to be configured with the info needed to talk to your DNS provider.  In our case, that's AWS Route 53.  

1. Edit `external-issuer.yaml` to set your region and hostedZoneID in the yaml and then create the ClusterIssuer.

2. Create the ClusterIssuer
```
kubectl apply -f external-issuer.yaml
```

## More Reading:
* https://cert-manager.io/docs/installation/
* https://cert-manager.io/docs/configuration/acme/dns01/route53/#eks-iam-role-for-service-accounts-irsa
* https://systemweakness.com/create-internal-ssl-certificates-with-cert-manager-851fc886628e




## (OPTIONAL SIDE QUEST) Create a ClusterIssuer for use internal to the k8s cluster

To demonstrate that you can have multiple ClusterIssuers, here are some instructions on how to create a ClusterIssuer for self-signed keys.  We're not using these in this demo.

There are times when we want to create TLS certificates for use only within the cluster.  For example, to keep the https chain in-place between the Intersystems API Manager and the IRIS FHIR server.  These can also be used to secure traffic within the IRIS cluster (ECP, Mirroring, etc)

1. Create a self-signed key for use as an internal Certificate Authority.

```
openssl req -x509 -newkey rsa:4096 -sha256 -days 365 -nodes  -keyout tls.key -out tls.crt  -subj /C=IN/ST=MH/L=PUN/O=TW/OU=IT/CN=ca.internal  -extensions ext  -config openssl.config
```

2. Create a k8s secret from the self-signed key.

```
kubectl create secret generic -n cert-manager internal-ca --from-file=tls.key --from-file=tls.crt
```

3. Create a cert-manager ClusterIssuer to create keys that are signed by the CA we just created

```
kubectl apply -f internal-issuer.yaml
```

