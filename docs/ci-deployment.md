# CI Deployment Instructions

Note: References to the use of Helper Scripts assume that you have already been through the [setting up of a single Python virtualenv for all of the helper scripts](https://github.com/Crown-Commercial-Service/ccs-migration-alpha-tools/blob/main/scripts/README.md).

## Beware: ACM Certs for the Buyer UI

The service of the Buyer UI is fairly complex, in a DNS sense. There is a public-facing FQDN, controlled outside the AWS workload account, to which client browsers send requests. That in turn is CNAMEd to the Route 53 record `aws_route53_record.buyer_ui`.

Because of this, the HTTPS listener on the ALB for Buyer UI needs to present a certificate not for the `aws_lb.buyer_ui` hostname but instead for the public-facing FQDN.

This fully-qualified domain name is provided to the stack via the variable `buyer_ui_public_fqdn`. The Terraform creates an ACM cert for that name but of course is powerless to create the CNAME certificate validation records for that domain, managed as it is by some external process.

Therefore the setup of this project differs somewhat from other migration projects - You are **VERY STRONGLY** encouraged to check out the below section on [applying Terraform for the first time](#first-time-terraform-apply) because otherwise you are likely to hit problems / Terraform timeouts.

## Overview

The process for deploying a service from this repo is as follows:

1. [Set up a Route 53 Hosted Zone](#route-53-hosted-zone) in the target AWS account
2. [Set up the cicd_infrastructure IAM role](#set-up-the-iam-role)
3. [Apply Terraform for the first time](#first-time-terraform-apply)
4. [Enable acting users / roles](#enable-acting-users--roles)
5. Set up [necessary SSM params](#necessary-ssm-parameters)
6. Build Docker image for each service (and test!)
7. [Log in](#logging-in-to-the-ecr-registry) the Docker CLI client to the ECR registry, which you will need to push the tested image
8. [Push the Docker image](#pushing-the-docker-images) to ECR
9. [Scale the services](#scale-or-redeploy-the-services) as you see fit

The non-standard steps are explained in more detail below.

## Route 53 Hosted Zone

The Terraform cannot be applied in the absence of a Route 53 Hosted Zone within the target AWS account. The zone also needs to be properly delegated from its parent domain. More information is to be found [in the developer setup docs](../iac/environments/development/README.md#route-53-hosted-zone).

You **must** complete this step properly before proceeding.

## Set up the IAM role

### TF Developers

If you're developing Terraform in your own sandbox using the [native-development environment](../iac/environments/native-development/README.md), then by convention the Terraform code acts through a role which is called `cicd_infrastructure`. Therefore the target AWS sandbox account needs to have this role set up in IAM. It will need Administrator permissions and (naturally) it must be possible for any acting users to assume it (this requires appropriate policy in both the Trust Relationship of
that role, and also in the policies of the IAM user who will adopt it).

### Non TF-Dev environments

By convention, the Terraform code acts through a role with Admin-like rights. This role should have been set up as part of the environment, and you will need to check with Ops for what the role is called.

## First-time `terraform apply`

The following is necessary owing to the cert situation [described above](#beware--acm-certs-for-the-buyer-ui).

1. Set variable `buyer_ui_public_cert_attempt_validation` to `false`. This will prohibit Terraform from awaiting the cert validation records
2. `terraform apply` as normal
3. Note the outputs `public_buyer_ui_cert_validation_records_required`, `public_buyer_ui_cname_source`, and `public_buyer_ui_cname_target` (see example below)
4. In the "parent" DNS management system, create a CNAME record for each of the objects in the output `public_buyer_ui_cert_validation_records_required`
5. In the "parent" DNS management system, create a CNAME record from the value of output `public_buyer_ui_cname_source`, pointing to the value of the output `public_buyer_ui_cname_target`
6. Set variable `buyer_ui_public_cert_attempt_validation` to `true`
7. `terraform apply` as normal

Examples of the output from initial `terraform apply` in step 2 above:

```hcl
public_buyer_ui_cert_validation_records_required = [
  {
    "name"  = "_5a4905dc69ec361dca7b4a3cfb1b2213.casbuyerui.example.com."
    "type"  = "CNAME"
    "value" = "_7298e0bcde42b386db5c72e70b4da6a6.mhbtsbpdnt.acm-validations.aws."
  },
]
public_buyer_ui_cname_source = "casbuyerui.example.com"
public_buyer_ui_cname_target = "cas-ui-aws.example.com"
```

Use the values of these outputs as directed in steps 3 thru 5.

## Enable acting users / roles

Managed IAM policies have been created to allow specific activities by users. For each policy there is a corresponding IAM group of the same name (to ease the empowerment of both IAM users or roles).

### IAM Policies

* _allow-ecr-login-and-push_ - Allows the holder to execute both `docker login` and `docker push` for the registry in the AWS account
* _run-api-service-command_ - Allows the holder to run a one-off command as the API service - required for running Rails migrations, for example
* _run-update-service_ - Allows the holder to run the [update service script](https://github.com/Crown-Commercial-Service/ccs-migration-alpha-tools/blob/main/scripts/update_service/update_service.py) which is the tool for scaling up or down the services

## Necessary SSM Parameters

SSM parameters need to be set up before you can deploy the services. The empty parameters are set up in [the manual_ssm_config.tf file](../iac/compositions/cat-full/manual_ssm_config.tf) and you can find a full list of them in that file.

## Docker image propagation

The services are Dockerised. They are deployed from images held at Amazon ECR. Therefore during your CI process you will need the ability to push acceptable, tested images to ECR. This will be done using the standard Docker command line tool. You will therefore need to be able to log in using this tool.

### Logging in to the ECR registry

Some scripts have been provided to make this a straightforward process - [See here](https://github.com/Crown-Commercial-Service/ccs-migration-alpha-tools/tree/main/scripts/ecr_repository/README.md) for more details. The command to effect this is as follows:

```bash
scripts/core/ecr_repository/get_login_password.py | docker login --username AWS --password-stdin `scripts/core/ecr_repository/get_ecr_registry_uri.py`
```

_(Note that the username is always `AWS` although counterintuitively this command will log you in to ECR Docker with the same permissions as your acting IAM user.)_

### Pushing the Docker images

Tag the built (and tested) Docker images with the following command:

```bash
docker tag API_IMAGE `scripts/core/ecr_repository/get_ecr_repository_uri.py api`
docker tag FRONTEND_IMAGE `scripts/core/ecr_repository/get_ecr_repository_uri.py frontend`
```

These will look up and assign the appropriate repo / tag values.

You can then push each of the Docker images to its appropriate ECR registry in the correct AWS account simply by running the commands below:

```bash
docker push `scripts/core/ecr_repository/get_ecr_registry_uri.py`/api
docker push `scripts/core/ecr_repository/get_ecr_registry_uri.py`/frontend
```

_Note that the admin service reuses the codebase from the API and so there are only two Docker images at play here.

### IAM enablers

It's intended this step is run by an IAM principal with restricted permissions. There exists both an IAM policy and an IAM group with the name `allow-ecr-login-and-push`. Any basic principal assigned the permissions therein will be able to run the above Docker Login command and also to push to the various ECR repos.

## Scale or redeploy the services

By default, each of the services is scaled to zero instances when the Terraform is applied. Services are deployed or terminated by scaling up or down the number of tasks for each service.

There is [a helper script](https://github.com/Crown-Commercial-Service/ccs-migration-alpha-tools/tree/main/scripts/update_service/update_service.py) to do this. It's basically a thin wrapper around the ECS `update-service` API call, with a waiter to ensure that (e.g.) a CI pipeline can be confident of moving on to a next step. See the script for details of uses but here is how you might scale up one of the services:

```bash
terraform -chdir=iac/environments/development output -json | scripts/core/update_service/update_service.py - web --scale-to=2
```

Beware: Note the hyphen `-` between the script filename and the service name. It's used to pipe the Terraform output into the script.

The script can also be used to perform a simple redeploy from ECR without scaling, as follows:

```bash
terraform -chdir=iac/environments/development output -json | scripts/core/update_service/update_service.py - web --redeploy
```

See [the script itself](https://github.com/Crown-Commercial-Service/ccs-migration-alpha-tools/tree/main/scripts/update_service/update_service.py) for full explanations.

It's intended this step is run by an IAM principal with restricted permissions. There exist both an IAM policy and an IAM group with the name `run-update-service`. Any basic principal assigned the permissions therein will be able to run the above command.

(Note that the IAM principal will also require the ability to read the Terraform state file in S3 because this script relies upon the output from `terraform output`).

### List of services

For reference, this is the complete list of services required for CAS - you will need to scale all of these for the system to function:

* [Buyer UI](../iac/compositions/cat-full/service_buyer_ui.tf)
* [CAT API](../iac/compositions/cat-full/service_cat_api.tf)
