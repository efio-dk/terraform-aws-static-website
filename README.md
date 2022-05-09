# Static site hosting resources
This is a Terraform module, creating all resources for hosting a static website on AWS.
Also serving as a reference architecture for such purpose.
Example of usage:
```
module "website" {
  source = "git@github.com:efio-dk/terraform-aws-static-website.git"
  FQDNs  = ["efio.dk", "www.efio.dk"]
  domain = "efio.dk"
}
```

### Prerequisites
* A preconfigured publicly available Route53 zone
