# Infrastructure and Architecture

This IAC project builds using the components in the core IAC repo. You are encouraged to read [the rationale behind this](https://github.com/Crown-Commercial-Service/ccs-migration-alpha-tools/blob/main/README.md) in detail in order to understand the choices and structures implemented in this project.

In short, modules in that repo are designed to be used as both:
  1. a backdrop of common structures; and
  2. a series of homogenous components

Both of these characteristics are intended to result in:
  * Predictable behaviours
  * Familiarity for engineers

## Network Architecture

The architecture model in the original project is based around a classic persistent-compute model, with various Load Balancers and Service Instances waiting for requests to process.

This style of structure necessitates a multi-tier network architecture. The core IAC repo provides a ready-built four-tier VPC model and you are encouraged to read [the documentation provided with that module](https://github.com/Crown-Commercial-Service/ccs-migration-alpha-tools/blob/main/modules/four-tier-vpc/README.md) to understand its use.

## Service Architecture

This application has two main component services:
* [Buyer UI](#buyer-ui)
* [CAT API](#cat-api)

These are discussed in more detail below.

### Buyer UI

The [Buyer UI service](compositions/cat-full/service_buyer_ui.tf) consists of:
* An Application Load Balancer in the _public_ subnet, sharing out the incoming requests
* An ECS Service in the _web_ subnet servicing those requests

The Buyer UI is written in [NodeJS](https://nodejs.org/en) and uses [Express](https://expressjs.com) to serve the web requests it receives.

### CAT API

The [CAT API](compositions/cat-full/service_cat_api.tf) consists of:
* An Application Load Balancer in the _public_ subnet, sharing out the incoming requests
* An ECS Service in the _application_ subnet servicing those requests

The CAT API is written in [Java](https://www.java.com/en/) and uses [Spring](https://spring.io) as a framework.
