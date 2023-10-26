# terraform-vault-nomad-setup

Terraform module that can be used to apply a default sample configuration to a
Vault cluster to integrate it with [Nomad workload identity][nomad_wid] JWTs.

## Usage

### Default sample configuration

This example uses the default sample configuration provided by the module. It
allows tasks to access secrets in the path `secret/<job namespace>/job ID>/*`.

```hcl
module "vault_setup" {
  source = "github.com/hashicorp/terraform-vault-nomad-setup"

  nomad_jwks_url = "https://nomad.example.com/.well-known/jwks.json"
}
```

### Custom policy

This example uses a custom policy to limit access to secrets in the path
`secret/<task name>/*` instead of the module's default.

```hcl
module "vault_setup" {
  source = "github.com/hashicorp/terraform-vault-nomad-setup"

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

## Resources

| Name | Type |
|------|------|
| [vault_jwt_auth_backend.nomad](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/jwt_auth_backend) | resource |
| [vault_jwt_auth_backend_role.nomad_workload](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/jwt_auth_backend_role) | resource |
| [vault_policy.nomad_workload](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_audience"></a> [audience](#input\_audience) | The `aud` value set on Nomad workload identities for Vault. Must match in Nomad, either in the agent configuration for `vault.default_identity.aud` or in the job task identity for Vault. | `string` | `"vault.io"` | no |
| <a name="input_default_policy_name"></a> [default\_policy\_name](#input\_default\_policy\_name) | The name of the default ACL policy created for Nomad workloads when `policy_names` is not defined. | `string` | `"nomad-workload"` | no |
| <a name="input_jwt_auth_path"></a> [jwt\_auth\_path](#input\_jwt\_auth\_path) | The path to mount the JWT auth backend used by Nomad. | `string` | `"jwt-nomad"` | no |
| <a name="input_nomad_jwks_url"></a> [nomad\_jwks\_url](#input\_nomad\_jwks\_url) | The URL used by Vault to access Nomad's JWKS information. It should be reachable by all Vault servers and resolve to multiple Nomad agents for high-availability, such as through a proxy or a DNS entry with multiple IP addresses. | `string` | n/a | yes |
| <a name="input_policy_names"></a> [policy\_names](#input\_policy\_names) | A list of ACL policy names to apply to tokens generated for Nomad workloads. | `list(string)` | `[]` | no |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | The name of the ACL role created and used by default for Nomad workload tokens. | `string` | `"nomad-workload"` | no |
| <a name="input_token_ttl"></a> [token\_ttl](#input\_token\_ttl) | The time-to-live value for tokens in seconds. Nomad attempts to automatically renew tokens before they expire. | `number` | `3600` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_auth_backend_accessor"></a> [auth\_backend\_accessor](#output\_auth\_backend\_accessor) | The accessor of the JWT auth backend created for Nomad tasks. |
| <a name="output_auth_backend_path"></a> [auth\_backend\_path](#output\_auth\_backend\_path) | The path of the JWT auth backend created for Nomad tasks. |
| <a name="output_nomad_client_config"></a> [nomad\_client\_config](#output\_nomad\_client\_config) | A sample Vault configuration to be set in a Nomad client agent configuration file. |
| <a name="output_nomad_server_config"></a> [nomad\_server\_config](#output\_nomad\_server\_config) | A sample Vault configuration to be set in a Nomad server agent configuration file. |
| <a name="output_policy_names"></a> [policy\_names](#output\_policy\_names) | The name of the ACL policies applied to tokens created using the Nomad JWT auth method. |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | The name of the ACL role applied to tokens created using the Nomad JWT auth method. |

[nomad_wid]: https://developer.hashicorp.com/nomad/docs/concepts/workload-identity
