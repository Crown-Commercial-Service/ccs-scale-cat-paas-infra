# CI Deployment Instructions

(wip)

## ACM Certs for the Buyer UI

The service of the Buyer UI is fairly complex, in a DNS sense. There is a public-facing FQDN, controlled outside the AWS workload account, to which client browsers send requests. That in turn is CNAMEd to the Route 53 record `aws_route53_record.buyer_ui`.

Because of this, the HTTPS listener on the ALB for Buyer UI needs to present a certificate not for the `aws_lb.buyer_ui` hostname but instead for the public-facing FQDN.

This fully-qualified domain name is provided to the stack via the variable `buyer_ui_public_fqdn`. The Terraform creates an ACM cert for that name but of course is powerless to create the CNAME certificate validation records for that domain, managed as it is by some external process.

Therefore the following dance is necessary when you deploy an environment for the first time:

### First-time `terraform apply`

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