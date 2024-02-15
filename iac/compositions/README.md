# Compositions

A layer of abstraction between Environments and Modules. The structure runs like this:

1. an Environment (such as "dev") invokes...
2. a particular Composition (such as "full-infra") using a series of variables which are specific to that original environment. The Composition then...
3. composes itself with a series of Modules

The purpose is to reduce the amount of duplicated code between the different environments, and to provide separation between the concepts of environment and project infrastructure.

## Helper Functions

Certain helper functions are included to assist with command-line operations of resources created by this Composition. Please see in particular:

* [ECR login, tag and push helper](https://github.com/Crown-Commercial-Service/ccs-migration-alpha-tools/blob/main/scripts/ecr_repository/README.md)
* [ECS service scaling and redployment helper](https://github.com/Crown-Commercial-Service/ccs-migration-alpha-tools/blob/main/scripts/update_service/update_service.py)

For assistance in setting up to run these scripts, please see: [setting up a single Python virtualenv for all of the helper scripts](https://github.com/Crown-Commercial-Service/ccs-migration-alpha-tools/blob/main/scripts/README.md).
