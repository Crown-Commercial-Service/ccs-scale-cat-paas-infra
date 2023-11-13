# ccs-scale-cat-paas-infra

## Checking out - Git Submodule

Note that this repo makes use of a Git submodule to load what's known as the Core infrastructure code. Therefore it will require slightly different operation compared to that of a single-repo checkout.

### Cloning, first time

In short, use the `--recurse-submodules` switch, thus:
```bash
git clone --recurse-submodules REPO_URL
```

### Pulling later changes

Likewise when you pull upstream changes, you will likely want to update the submodule in step with the main repo. This is achieved as follows:

```bash
git pull --recurse-submodules origin main
```

### Further reading

If you are intending to amend any of the submodule code, you will need to be aware of how to manage inter-dependent Git modules in the same file tree. The [offical Git docs](https://git-scm.com/book/en/v2/Git-Tools-Submodules) are a pretty good place to start.

## Local initialisation & provisioning (sandbox spaces only)

Terraform state for each space (environment) is persisted to a dedicated AWS account. Access keys for an account in this environment with the appropriate permissions must be obtained before provisioning any infrastructure from a local development machine. The S3 state bucket name and Dynamo DB locaking table name must also be known.

1. The AWS credentials, state bucket name and DDB locking table name must be supplied during the `terraform init` operation to setup the backend. `cd` to the `terraform/environments/{env}` folder corresponding to the environment you are provisioning, and execute the following command to initialise the backend:

```
terraform init \
   -backend-config="access_key=ACCESS_KEY_ID" \
   -backend-config="secret_key=SECRET_ACCESS_KEY" \
   -backend-config="bucket=S3_STATE_BUCKET_NAME" \
   -backend-config="dynamodb_table=DDB_LOCK_TABLE_NAME"
```

Note: some static/non-sensitive options are supplied in the `backend.tf` file. Any sensitive config supplied via command line only (this may change in the future if we can use Vault or similar).

This will ensure all Terraform state is persisted to the dedicated bucket and that concurrent builds are prevented via the DDB locking table.

## Provision the service infrastructure via Travis

The main environments are provisioned automatically via Travis CI. Merges to key branches will trigger an automatic deployment to certain environments - mapped below:

- `develop` branch -> `development` space
- `release/int` branch -> `int` space
- `release/nft` branch -> `nft` space
- `release/uat` branch -> `uat` space
- `release/pre` branch -> `pre-production` space
- `release/prd` branch -> `production` space
- feature branches can be deployed to specific sandboxes by making minor changes in the `travis.yml` file (follow instructions)

## Provision the service infrastructure from a local machine (sandbox spaces only)

We use Terraform to provision the underlying service infrastructure in a space. We will need to supply the Cloud Foundry login credentials for the user who will provision the infrastructure (Note: it may be better to create a special account for this).

These credentials can be supplied in one of 3 ways:

- via a `secret.tfvars` file, e.g. `terraform apply -var-file="secret.tfvars"` (this file should not be committed to Git)
- via input variables in the terminal, e.g. `terraform apply -var="cf_username=USERNAME" -var="cf_password=PASSWORD"`
- via environment variables, e.g. `$ export TF_VAR_cf_username=USERNAME`

Assume one of these approaches is used in the commands below (TBD)

1. Run `terraform plan` to confirm the changes look ok
2. Run `terraform apply` to provision the resources

## Create Tables

The Terraform scripts will provision an empty Tenders Database. We need to create the tables.

Prerequisite - install conduit on your local machine (see https://docs.cloud.service.gov.uk/deploying_services/postgresql/#connect-to-a-postgresql-service-from-your-app for details)

The scripts are located here: https://github.com/Crown-Commercial-Service/ccs-scale-db-scripts. Checkout the `develop` branch and `cd` to the `tenders-api` folder.

1. Create the tables using `cf conduit {env}-ccs-scale-cat-tenders-pg-db -- psql < ddl.sql`

At the time of writing there is no seed data for the Tenders DB.
