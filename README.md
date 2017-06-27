# govuk-kubernetes-discovery

This repository contains the results of a discovery into hosting/kubernetes as a container orchestration solution for GOV.UK.

This repository is a clean-clone of [another (private)](https://github.com/alphagov/govuk-hosting-discovery) that contained various pieces of sensitive data which have been removed from this copy.

By the end of the discovery several approaches had been tested so not all of this repository is in a working state.

## History

This project went through several stages:

1. Initial discovery on [Google Container Engine (GKE)](https://cloud.google.com/container-engine/) using a manually deployed cluster. Used [government-frontend](github.com/alphagov/government-frontend) as a test app.
2. Work on templating kubernetes manifests ([`/govuk-k8s-deployment`](/govuk-k8s-deployment)).
3. GKE [HTTP Load Balancer](https://cloud.google.com/container-engine/docs/tutorials/http-balancer) for ingress.
4. [Terraformed](https://terraform.io) GKE cluster deployment.
5. Database creation in [Cloud SQL](https://cloud.google.com/sql/) for the [release app](https://github.com/alphagov/release).
6. [Persistent Volume](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) work for hosting [Mongo](https://www.mongodb.com/) in cluster to run [content-store](https://github.com/alphagov/content-store).
7. Changed Terraform to build in [AWS](https://aws.amazon.com).
8. Introduced [kube-aws](https://github.com/kubernetes-incubator/kube-aws) to build the cluster.
9. AWS [Application Load Balancer](https://aws.amazon.com/elasticloadbalancing/applicationloadbalancer/) for ingress (with echoserver).


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

