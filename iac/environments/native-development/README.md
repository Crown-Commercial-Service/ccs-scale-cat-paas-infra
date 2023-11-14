# native-development

Development of native AWS (i.e. post GPaaS migration) provision.

## Single developer account

The "development" environment is for the provision of a single-developer sandbox account, inside its own separate AWS account.

This is not an environment for a collective, shared dev installation. Therefore the setup instructions below will not be for that use case.

## Setting up

### Local vars

Copy local.auto.tfvars.example to local.auto.tfvars. Populate the variable values according to the instructions in the file. (This file is ignored by Git version control so you do not accidentally check your own settings into the repo.)

When editing this file, it's a good idea to make sure that the variables are always listed in alphabetical order - it may help you later.
