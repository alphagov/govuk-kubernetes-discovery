# Kubernetes Manifests and Secrets Deployment

## sops

Use [sops](https://github.com/mozilla/sops) to edit a secrets file.

Install sops:

`brew install sops`

To use KMS, export your AWS keys:

```
export AWS_ACCESS_KEY_ID=<id>
export AWS_SECRET_ACCESS_KEY=<key>
```

`sops <app>/integration_secrets.yaml`

## Deploy secrets and configmaps

Secrets and configmaps **must** be deployed **before** any manifests are deployed.

```
export ENVIRONMENT=integration
export KUBE_NAMESPACE=frontend
export APPLICATION=release
bundle install
bundle exec rake kubectl:create_secrets
bundle exec rake kubectl:create_configmaps
```

## Deploy manifests

`kubectl apply -f manifests/$APPLICATION`

## Structure

Application structure separates manifests and data. The structure for an application
should look like the following:

```
├── data
│   └── my-awesome-app
│       └── development_secrets.yaml
└── manifests
    └── my-awesome-app
        ├── deployment.yaml
        └── service.yaml
```

## Authentication with an AWS Cluster

Please see the [kube-aws documentation](../kube-aws/README.md) for more details.

## Authentication with GKE cluster

If you're using a key file:

`gcloud auth activate-service-account --key-file $GOOGLE_APPLICATION_CREDENTIALS`

Find the project name:

`gcloud config list`

Fill in the appropriate values below:

```
gcloud config set project <project name>
gcloud config set compute/zone <zone>
gcloud config set container/cluster <cluster name>
gcloud config set container/use_client_certificate True
gcloud container clusters get-credentials <cluster name>
export KUBECONFIG=./kubeconfig
```

