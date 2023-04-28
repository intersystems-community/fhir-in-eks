# Create a kubernets cluster

`eksctl` allows all your options to be included in a configuration file that describes all your cluster options.  There's an example included in the eksctl directory. Review this, edit it to meet your needs and then you can create the cluster.  I've called my cluster `summit-fhir`.  You'll definitely want to change that.

```
eksctl create cluster -f eks-cluster.yaml
```

You can veryify that this worked correctly with the following commands:
`eksctl get cluster summit-fhir`
`eksctl get nodegroup --cluster summit-fhir`

The `eks-cluster.yaml` added the addons and IAM settings to enable AWS EBS volume management in kubernetes.  It also creates the IAM roles needed for DNS and SSL key management.

This also creates a default `StorageClass` - gb2 - that's connected to EBS.  

This currently takes about 20 minutes to complete.

## Further Reading:
* https://eksctl.io/
* https://docs.aws.amazon.com/eks/latest/userguide/csi-iam-role.html
* https://kubernetes.io/docs/concepts/storage/storage-classes/
