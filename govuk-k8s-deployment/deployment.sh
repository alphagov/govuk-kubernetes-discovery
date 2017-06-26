#!/bin/bash

bundle install --path "${HOME}/bundles/${JOB_NAME}"

export KUBECONFIG=./kubeconfig
export ENVIRONMENT=integration
export CLUSTER_NAME=govuk-application
export APPLICATION=${TARGET_APPLICATION}
export TAG=${TAG}
export OUTPUTDIR=output

gcloud auth activate-service-account --key-file $GOOGLE_APPLICATION_CREDENTIALS
gcloud config set project govuk-${ENVIRONMENT}
gcloud config set compute/zone europe-west1-b
gcloud config set container/cluster ${CLUSTER_NAME}
gcloud container clusters get-credentials ${CLUSTER_NAME}


mkdir ${OUTPUTDIR}
bundle exec rake generate:namespace
bundle exec rake generate:configmaps
bundle exec rake generate:secrets
bundle exec rake generate:deployment
bundle exec rake generate:service
bundle exec rake generate:ingress

for resource in namespace configmap secret deployment service ingress ; do
  for file in $(ls ${OUTPUTDIR}/${resource}-*) ; do
    echo "Applying configuration ${file} ..."
    kubectl apply -f ${file}

    if [ $? -ne 0 ] ; then
      echo "ERROR applying configuration, some resources might not work as expected"
    fi
  done
done
