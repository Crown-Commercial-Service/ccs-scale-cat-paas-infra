# Compositions

A layer of abstraction between Environments and Modules. The structure runs like this:

1. an Environment (such as "dev") invokes...
2. a particular Composition (such as "full-infra") using a series of variables which are specific to that original environment. The Composition then...
3. composes itself with a series of Modules

The purpose is to reduce the amount of duplicated code between the different environments, and to provide separation between the concepts of environment and project infrastructure.
