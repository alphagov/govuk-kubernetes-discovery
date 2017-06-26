# Persistent Storage & Stateful Sets

## Intro ##

Several of our apps require an amount of persistent storage (for example Redis, Mongodb). In a kubernetes cluster pods are inherently short-lived and not attached to any specific node. The Kubernetes solution to this is to use[statefulset](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/) ([API](https://kubernetes.io/docs/api-reference/v1.6/#statefulset-v1beta1-apps)).

A stateful set is a collection of pods which are brought up in a defined order and given predictable names. If they're associated with persistent storage then the same storage will be associated with the same pod name. This means that if the pod "mongo-1" is destroyed and recreated (even on a different node) then the storage volume associated with that pod will be re-attached to the new version of the pod.

## How-to ##

There are several steps to creating a statefulset with persistent storage.

1. Create a [StorageClass](https://kubernetes.io/docs/api-reference/v1.6/#storageclass-v1-storage) manifest. This will depend on the k8s host (i.e. GKE, AWS) and controls creation and assignment of the volume
2. Create a [Headless Service](https://kubernetes.io/docs/concepts/services-networking/service/#headless-services) for the set.
3. Create a statefulset manifest with a volumeClaimTemplate.

## Mongo ##

This has been tested with mongod (see the mongodb & content-store manifests). The main things to note are:

* Use of the mongo-k8s-sidecar container to initialises each pod. Other options are possible using init-containers, for example the [helm chart](https://github.com/kubernetes/charts/blob/master/stable/mongodb-replicaset/templates/mongodb-statefulset.yaml#L22).
* The app that uses the database (in this case, content-store) should have its database URL use the full name of each mongo instance:
```
<pod>-0.<service>.<namespace>.svc.cluster.local,<pod>-1....
```
