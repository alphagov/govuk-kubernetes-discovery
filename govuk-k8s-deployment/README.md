# Kubernetes deployments with Jenkins

## Generate Kubernetes resources configuration

### Install scripts

```
bundle install
```

### Generate kubeconfig credentials from a Google credentials file

If you don't have a kubeconfig file to connect with the Google Kubernetes cluster, you can generate a temporal one
from your credentials file:

```
export GOOGLE_APPLICATION_CREDENTIALS=<path-to-credentials-file>
export KUBECONFIG=./kubeconfig
gcloud auth activate-service-account --key-file ${GOOGLE_APPLICATION_CREDENTIALS}
gcloud config set project govuk-integration
gcloud config set compute/zone europe-west1-b
gcloud config set container/cluster <cluster-name>
gcloud container clusters get-credentials <cluster-name>
```

### Environment variables

```
export ENVIRONMENT=integration
export APPLICATION=<application>
export TAG=<tag>
export OUTPUTDIR=output
```

### Generate Kubernetes resource files

```
mkdir ${OUTPUTDIR}
bundle exec rake generate:namespace
bundle exec rake generate:configmaps
bundle exec rake generate:secrets
bundle exec rake generate:deployment
bundle exec rake generate:service
bundle exec rake generate:ingress
```

### Apply resources

Namespaces, secrets and configmaps need to exist before creating other resources

```
for file in $(ls ${OUTPUTDIR}/namespace-*) ; do kubectl apply -f ${file} ; done
for file in $(ls ${OUTPUTDIR}/configmap-*) ; do kubectl apply -f ${file} ; done
for file in $(ls ${OUTPUTDIR}/secret-*) ; do kubectl apply -f ${file} ; done
for file in $(ls ${OUTPUTDIR}/deployment-*) ; do kubectl apply -f ${file} ; done
for file in $(ls ${OUTPUTDIR}/service-*) ; do kubectl apply -f ${file} ; done
for file in $(ls ${OUTPUTDIR}/ingress-*) ; do kubectl apply -f ${file} ; done
```

## Examples and discussion around container deployments with Jenkins

#### Discussion: do we want to have the deployment and service description within each application repository or in a central dedicated repo?

This repository assumes the Kubernetes files are in a different repository

#### Discussion: how do we pass properties to the containers?

Currently the applications source the files in /etc/govuk/<app> via wrapper script. Properties
can also be added to the container during its creation as environment variables.

Environment variables can be created as part of the container template with the 'env' key, or as configmaps.
Configmaps allow us to separate the data in a ConfigMap resource that is independent from the
Deployment resource. Configmaps can expose properties directly as environment variables (envfrom key) or via mounted 
volume, in which case it creates a directory structure similar to the current /etc/govuk with one file per
variable.

This repository assumes we use configmaps and envfrom to expose properties to the container as environment variables.

#### Discussion: how do we pass secrets to the containers?

Similar to configmaps, the Secrets resource can create environment variables in the container or
can create a directory in /etc/govuk with files containing the secrets.

There is a big discussion around how secrets the Secrets are, it's worth to read the "Risks" section
in https://kubernetes.io/docs/concepts/configuration/secret .

When creating secrets, the file with the data needs to have each value encoded with base64.

Something to have a look at in the future in Vault, but it needs in-house work to be integrated with K8s:
- https://github.com/kubernetes/kubernetes/issues/10439 
- https://medium.com/on-docker/secrets-and-lie-abilities-the-state-of-modern-secret-management-2017-c82ec9136a3d

#### Discussion: how do we design namespaces?

Some resources are only available to pods in the same namespace. That's the case for configmaps and secrets,
so probably we need a namespace per pod.

#### How can we interact with the Kubernetes cluster from the Jenkins machine?

We created a separate service account with permissions to administer container clusters in govuk-integration.
The credentials file has been added to the Jenkins credentials as a secret file.

To manage Kubernetes cluster we can use kubectl. A quick way of using only the service account credentials with kubectl is:

```
export GOOGLE_APPLICATION_CREDENTIALS=<file to creds>
# Path to save kubeconfig
export KUBECONFIG=<path to kubeconfig>
# This command provides temporal credentials to use in the kubeconfig file
gcloud container clusters get-credentials CLUSTERNAME
kubectl --kubeconfig=${KUBECONFIG} <command>
```

#### Discussion: how do we distribute secrets and config variables in the Jenkins boxes?

As we move to containers we could start removing Puppet code, but Jenkins still needs to pull
config variables and secrets that currently live in govuk-puppet and deployment repos to configure
the config/secret maps.

This repository contains a data directory where secrets are encrypted with eyaml-gpg.

#### Minikube

With minikube we can test deployments/containers locally: https://kubernetes.io/docs/getting-started-guides/minikube/

To test the files under this directory, the namespace needs to exist before the rest of resources, and configmaps need
to exist before the container, for instance:

```
# Make sure you are in the minikube context
 $ kubectl config current-context
minikube
```

To access the service you need to use the IP associated with the Minikube VM network adapter.

