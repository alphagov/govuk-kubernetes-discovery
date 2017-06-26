# govuk-hosting-discovery

A repo to hold our GOVUK hosting discovery notes and code.

This project is still in alpha.

## Documentation

### ADR

We use Architecture Decision Records to keep a track of decisions we make across
the course of this alpha. These can be found [here](doc/architecture/decisions).

### Components

There is some information regarding different components of our architecture. These
can be found [here](doc/components).

### Google Cloud

The first part of our alpha we explored Google Cloud Platform. Some notes can be
found [here](googlecloud.md), and we also retain some Terraform files to build
a fresh cluster.

## Terraform

We are using Terraform to provision our infrastructure.

Please see the [documentation](terraform/README.md) for further details.

## Kubernetes

A large part of our discovery is working with Kubernetes to deploy our applications
as containers. Kubernetes provides the networking and deployment model for our
container based environment.

Please see the [documentation](kubernetes/README.md) for more details.

We store our manifests [here](kubernetes/manifests).

### Kubernetes in AWS

We are using [CoreOS](https://coreos.com/) for our deployment of a Kubernetes cluster.

To create and interact with a Kubernetes cluster provisioned in AWS, please see the documentation
regarding [kube-aws](kube-aws/README.md).

