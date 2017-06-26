# Kubernetes on AWS

## Installation

Our Kubernetes clusters are managed with `kube-aws`. You need to download the latest stable release
from https://github.com/kubernetes-incubator/kube-aws/releases/tag/v0.9.6

We follow the configuration instructions from kube-aws: https://github.com/kubernetes-incubator/kube-aws
Make sure you read the document to understand the steps that we are going to perform and, before starting, 
configure your AWS credentials as explained in the CoreOS documentation.

## Cluster parameters

`kube-aws` needs some preexisting AWS resources: EC2 key pair, KMS key, external DNS name and S3 bucket.
These resources are managed by the Terraform `govuk-kubernetes-<cluster>` stack, so it needs to be
applied before proceeding to create the cluster.

## Initialise Assets directory

This directory contains a sub-directory for each Kubernetes cluster/environment that we are going to manage,
in the way `<cluster-name>/<environment>`

As explained in the CoreOS documentation, the `kube-aws init` command initialises the CloudFormation stack 
with the parameters created by Terraform. This command generates a `cluster.yaml` file that we can
customise to meet our requirements.

The output of the following command is saved in `cluster-<kube-aws-version>.yaml`:

```
$ kube-aws init --cluster-name=GOVUK_CLUSTER_NAME \
                --hosted-zone-id=GOVUK_ZONE_ID \
                --key-name=GOVUK_EC2_KEY_NAME \
                --kms-key-arn=GOVUK_KMS_KEY_ARN \
                --region=GOVUK_REGION \
                --external-dns-name=GOVUK_API_DNS_NAME \
                --availability-zone=GOVUK_AVAILABILITY_ZONE
```

Copy this file to `<cluster-name>/<environment>/cluster.yaml` and edit the GOVUK_ keys for the cluster. Additionally,
consider adding the following settings:
- Add a list of AllowedSourceCIDRs to restrict SSH access to GOV.UK IPs. kube-aws will create security groups
with these IPs. On the other hand, we can manage the SGs externally (Terraform) and add the IDs to the configuration
- Set autoScalingGroup, etcd count and subnets to deploy multiple instances of master, workers or etcd on multiple
availability zones
- We are managing our VPC and subnets with Terraform, so the vpcId, routeTableId and subnets settings in the 'network'
section need to be configured properly

## Render certificates

`kube-aws` provides a command to generate the cluster certificates. This is NOT recommended for production.

Certificates in this repository are encrypted with Sops and use a .enc_sops file extension. If you are generating
new certificates and want to commit them to the repository, run:

```
$ cd credentials
$ for i in $(ls *.pem) ; do sops -e $i > $i.enc_sops; done
```

Remove the `credentials/.gitignore` file to commit your changes.

To decrypt all the certificates, run:

```
$ cd credentials
$ for i in $(ls *.enc_sops | sed 's/.enc_sops//'); do sops -d $i.enc_sops > $i; done
```

## Render, validate and apply cluster assets

```
$ kube-aws render stack
$ kube-aws validate --s3-uri s3://<your-bucket-name>/<prefix>
$ kube-aws up --s3-uri s3://<your-bucket-name>/<prefix>
```

kube-aws generates the `kubeconfig` file to authenticate with the cluster. This also needs to be encrypted
before committing in the repository. At the moment we are placing the file in the credentials directory:

```
$ vim kubeconfig # remove credentials/ path from certificates
$ sops -e kubeconfig > credentials/kubeconfig.enc_sops
$ rm kubeconfig
```

## Authenticate with a specific stack

1. Export your AWS credentials
2. `cd credentials`
3. `for i in $(ls *.enc_sops | sed 's/.enc_sops//'); do sops -d $i.enc_sops > $i; done`
4. `export KUBECONFIG=$(pwd)/kubeconfig`
5. `kubectl get nodes`

## Additional configuration for ALB Ingress Controller

The `govuk-kubernetes-application` Terraform project creates additional resources that
need to be updated on the cluster after creation:

- Attach `kubernetes_alb_ingress_controller_policy_arn` to the Kubernetes Worker IAM role. `kube-aws` version 0.9.7 will allow to attach policies to
nodes in the cluster.yaml, until then this needs to be done manually. Check https://github.com/kubernetes-incubator/kube-aws/issues/340
for more information

- Add `security_group_alb_worker_controller_id` to the Kubernetes Worker security groups, to enable access from ALBs created with the Ingress Controller

For more information about `kube-aws` or how to customise the cluster, read the provider documentation.

