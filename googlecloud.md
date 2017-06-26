# Google Cloud Platform

The first part of our discovery was spent looking into Google Cloud. Documented
here are the notes we sourced from this work.

## Create a Google Container Engine cluster by hand

The following commands will create a Google Container Engine (GKE) cluster running the [government frontend](https://github.com/alphagov/government-frontend) service. It will also deploy the [Release app](https://github.com/alphagov/release) but this will not work unless the steps in [Deploying the Release app](#Deploying-the-Release-app) have been followed.

```bash
gcloud config set project <project-id>
gcloud container clusters create \
    --num-nodes=1 \
    --zone=europe-west1-b \
    --additional-zones europe-west1-c,europe-west1-d \
    <cluster-name>
gcloud auth application-default login
```

This will create a GKE cluster called `<cluster-name>` in the project '<project-id>' (e.g. 'govuk-test') with 1 node per zone (and 3 zones). Ensure kubectl has the correct auth tokens by verifying you with Google.

To view the kubernetes dashboard run:
```bash
kubectl proxy
```

then go to [127.0.0.1:8001/ui](127.0.0.1:8001/ui).

## Load Balancing

Load balancing is done using a [Google L7 Load balancer](https://cloud.google.com/container-engine/docs/tutorials/http-balancer). Each service to be balanced is exposed as a [NodePort Service](https://kubernetes.io/docs/concepts/services-networking/service/#type-nodeport) in Kubernetes and then these are added to the load balancer using an [Ingress Controller](https://kubernetes.io/docs/concepts/services-networking/ingress/).

The load balancer will also terminate SSL.

It's important to note that the number of services that can be routed by the load balancer is limited by the [backend-service quota](https://github.com/kubernetes/ingress/blob/master/controllers/gce/BETA_LIMITATIONS.md).

## Google Container Registry

Google Container Registry (GCR) is google's equivalent to [Docker hub](https://hub.docker.com/). It is accessible from GKE and can store public or private images.

To push an image to GCR:
```bash
docker build -t gcr.io/<project-id>/<image-name> .
gcloud docker -- push gcr.io/<project-id>/<image-name>
```

If you run:
```bash
gcloud container images list --filter=<image-name>
```
you should see your image. If you've pushed to an existing image you can check the tags for it using:
```bash
gcloud container images list-tags gcr.io/<project-id>/<image-name>
```

You can also add and remove tags, and delete images (using `gcloud container images` plus `add-tag`, `untag` and `delete` respectively, check `gcloud container images --help`).

## References

* [GKE quickstart](https://cloud.google.com/container-engine/docs/quickstart)
* [GCR quickstart](https://cloud.google.com/container-registry/docs/quickstart)
* [GCR image management](https://cloud.google.com/container-registry/docs/managing
