# GOV.UK Kubernetes Terraform resources

## Installation

- [Terraform](https://www.terraform.io/): we use remote state files, which means you can't plan/apply changes if the
version of your local Terraform doesn't match the version that generated the remote state. Currently we assume 0.9.5
- [Sops](https://github.com/mozilla/sops)

## Dependencies

### Google Cloud credentials

These are only required when deploying a GKE cluster.

If you don't have a credentials file, you need to generate one:

```
export GOOGLE_PROJECT=govuk-integration
gcloud auth login
gcloud iam service-accounts create $USER
gcloud projects add-iam-policy-binding govuk-integration --member serviceAccount:$USER@${GOOGLE_PROJECT}.iam.gserviceaccount.com --role roles/editor
gcloud iam service-accounts keys create credentials.json --iam-account $USER@${GOOGLE_PROJECT}.iam.gserviceaccount.com
```

### AWS credentials

To encrypt secrets with Sops, you need access to the AWS KMS key specified in `.sops.yaml`. If you have an account with
the right permissions, you need to add the AWS variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` to your environment, or 
configure a AWS profile with the right credentials.

## Google-related Environment variables

```
export GOOGLE_APPLICATION_CREDENTIALS=<path-to-credentials.json>
```

## Manage resources

The tfstate bucket needs to exist.

```
cd <project>

# Initialise stack
terraform init --backend-config=./integration.backend

# Decrypt secrets
sops -d ../../data/<project>/integration_secrets.json > _integration_secrets.json

# Check changes:
terraform plan --var-file=../../data/<project>/common.tfvars --var-file=../../data/<project>/integration.tfvars --var-file=./_integration_secrets.json

# Apply changes:
terraform apply --var-file=../../data/<project>/common.tfvars --var-file=../../data/<project>/integration.tfvars --var-file=./_integration_secrets.json
```

## Overriding variables

If a variable from a file needs to be overridden this can be done by specify the desired value after the file e.g.:

```
terraform apply -var-file=./integration.tfvars -var google_project=govuk-test
```
