# Zero Go Home

## Setup accounts
Azure
```
az login -u user@example.com
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$SUBSCRIPTION_ID"
```

### GCP
Configure gcloud authentication.  Uses application-default-login or explicit configured credentials.
 * https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference#authentication

Using application-default-login (account global!):
```
gcloud auth application-default login
gcloud config configurations list
gcloud config list
```

Using service key credentials:
* https://console.cloud.google.com/apis/credentials/serviceaccountkey

You must also:
* Enable the APIs, which requires billing to be enabled and associated.

### Aws

The Debian default username is admin.


## SSH
```
ssh $(terraform output -json zero_ipv6 |jq -r)
ssh $(terraform output -json zero_ipv4 |jq -r)
```

