# Deployment

## To template or to not template

## Templating with ERB

- Seperated data into separate file using YAML
- Encrypted secrets using eYAML and GPG

## Helm

- Shiny tool to do stuff
- Did templating in Go templating language
- Did deployments nicely: `helm upgrade foo --version 1.2.0`
- Packaged manifests and then could store them in a repo
- Good for rolling out components for testing ie `helm install stable/mongodb`
- Requires it's own pod on the cluster: "helm tiller" (HA?)

- Unclear on the deployment methods it applies
- Templating seemed convoluted
- Doesn't really suit our needs or solve any problems

## Add data in ConfigMaps

Store data in configMaps which are loaded in through the manifest as opposed to
listing environment variables as a list in the manifest

## Jenkins job

### Using templates

Generated config then used `kubectl apply` to push any changes
