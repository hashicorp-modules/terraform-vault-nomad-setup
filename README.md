# terraform-vault-nomad-setup

Terraform module that can be used to apply a default sample configuration to a
Vault cluster to integrate it with [Nomad workload identity][nomad_wid] JWTs.

Terraform Registry:
https://registry.terraform.io/modules/hashicorp-modules/nomad-setup/vault/

## Usage

### Default sample configuration

This example uses the default sample configuration provided by the module. It
allows tasks to access secrets in the path `secret/<job namespace>/job ID>/*`.

```hcl
module "vault_setup" {
  source = "hashicorp-modules/nomad-setup/vault"

  nomad_jwks_url = "https://nomad.example.com/.well-known/jwks.json"
}
```

### Custom policy

This example uses a custom policy to limit access to secrets in the path
`secret/<task name>/*` instead of the module's default.

```hcl
module "vault_setup" {
  source = "hashicorp-modules/nomad-setup/vault"

  nomad_jwks_url = "http://localhost:4646/.well-known/jwks.json"
  policy_names = [
    vault_policy.task_path.name,
  ]
}

resource "vault_policy" "by_nomad_task" {
  name   = "by-nomad-task"
  policy = <<EOT
path "secret/data/{{identity.entity.aliases.${module.vault_setup.auth_backend_accessor}.metadata.nomad_task}}/*" {
  capabilities = ["read"]
}

path "secret/data/{{identity.entity.aliases.${module.vault_setup.auth_backend_accessor}.metadata.nomad_task}}" {
  capabilities = ["read"]
}

path "secret/metadata/{{identity.entity.aliases.${module.vault_setup.auth_backend_accessor}.metadata.nomad_task}}/*" {
  capabilities = ["list"]
}

path "secret/metadata/*" {
  capabilities = ["list"]
}
EOT
}
```

### Vault Namespace

When using Vault Enterprise you can apply the configuration to a different
namespace by configuring the `vault` provider.

```hcl
provider "vault" {
  # ...
  namespace = "prod"
}
```

Create different [provider aliases][tf_provider_alias] to support multiple
namespaces.

```hcl
provider "vault" {
  # ...
}

provider "vault" {
  alias = "prod"
  # ...
  namespace = "prod"
}

module "vault_setup" {
  source = "hashicorp-modules/nomad-setup/vault"
  providers = {
    vault = vault.prod
  }
  # ...
}
```

[nomad_wid]: https://developer.hashicorp.com/nomad/docs/concepts/workload-identity
[tf_provider_alias]: https://developer.hashicorp.com/terraform/language/providers/configuration#alias-multiple-provider-configurations
