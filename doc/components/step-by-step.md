# GOV.UK infrastructure steps

## Infrastructure plan

- AWS dedicated VPC and custom subnets
- AWS dedicated DNS zone
- Single CoreOS Kubernetes cluster, multiple regions, version 1.6.x
- Namespaces match original VCloud VPCs names

## Build guide

### GOV.UK Network Base infrastructure

TF project: govuk-network-base

This stack creates a dedicated VPC network, IGW and IGW route

### Kubernetes application cluster

TF project: govuk-kubernetes-application

The Terraform stack creates the managed resources for kube-aws, which include:
- Subnets
- Security groups
- Key pair
- KMS key
- S3 bucket

The Kubernetes cluster is managed with `kube-aws`. The resources are stored in 
`kube-aws/govuk-application/<environment>`

### Release application resources

TF project: release

This stack manages the RDS instance and its subnets, and DNS resources for the Release application

### Kubernetes Base resources

- KUBECONFIG points to the kubeconfig file path
- ENVIRONMENT is used to find the configuration file in the data directory

```
 $ export KUBECONFIG=<path-to-kubeconfig>
```

Generate namespaces:

```
 $ kubectl apply -f manifests//base/frontend-namespace.yaml
```

#### ALB ingress-controller

The alb-ingress-controller can configure HTTPS listeners with certificates managed by AWS Certificate Manager.
At the moment it doesn't look like Terraform supports this resource (https://github.com/hashicorp/terraform/issues/4782),
so we need to do it manually or automate with the AWS CLI. The certificate ARN will be referenced in the ingress resource for each service.

Install the alb-ingress-controller from the given manifests:

```
 $ kubectl apply -f manifests/base/alb-ingress-controller-default-backend.yaml
 $ kubectl apply -f manifests/base/alb-ingress-controller.yaml
```

The ingress-controller will only "listen" to ingress resources with the annotation
`kubernetes.io/ingress.class: "alb"` on any namespace (namespaces can be restricted in the alb-ingress-controller.yaml
configuration)

Check all the configuration details in https://github.com/coreos/alb-ingress-controller and the example in `manifests//base/echo-ingress.yaml`

### Kubernetes government-frontend application

Generate configmaps/secrets with Rake tasks:

```
 $ export KUBE_CONFIG=$KUBECONFIG
 $ export ENVIRONMENT=development
 $ export KUBE_NAMESPACE=frontend
 $ export APPLICATION=government-frontend
 $ bundle exec rake kubectl:create_configmaps
 $ bundle exec rake kubectl:create_secrets
```

Apply rest of resources:

```
 $ kubectl apply -f manifests/government-frontend/deployment.yaml
 $ kubectl apply -f manifests/government-frontend/service.yaml
 $ kubectl apply -f manifests/base/frontend-ingress.yaml
```

Test accessing https://<static-ip>/government/collections/business-statements-office-of-the-leader-of-the-house-of-commons

### Kubernetes release application

- The database username and password created by the Terraform release stack need to be added to the DATABASE_URL parameter in data/release
- The database name created by the Terraform release stack needs to be updated in manifests/release/deployment.conf

```
 $ export KUBE_CONFIG=$KUBECONFIG
 $ export ENVIRONMENT=development
 $ export KUBE_NAMESPACE=frontend
 $ export APPLICATION=release
 $ bundle exec rake kubectl:create_secrets
```


