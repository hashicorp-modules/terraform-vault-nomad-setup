# terraform-vault-nomad-setup

Terraform module that can be used to apply a default sample configuration to a
Vault cluster to integrate it with [Nomad workload identity][nomad_wid] JWTs.

## Usage

```hcl
module "vault_setup" {
  source = "github.com/hashicorp/terraform-vault-nomad-setup"

  nomad_jwks_url = "https://nomad.example.com/.well-known/jwks.json"
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
| <a name="input_audience"></a> [audience](#input\_audience) | The `aud` value set on Nomad workload identity JWTs. | `string` | `"vault.io"` | no |
| <a name="input_jwt_auth_path"></a> [jwt\_auth\_path](#input\_jwt\_auth\_path) | The path to mount the JWT auth backend used by Nomad. | `string` | `"jwt-nomad"` | no |
| <a name="input_nomad_jwks_url"></a> [nomad\_jwks\_url](#input\_nomad\_jwks\_url) | The URL used by Vault to access Nomad's JWKS information. | `string` | n/a | yes |
| <a name="input_policy_name"></a> [policy\_name](#input\_policy\_name) | The name of the policy created and used to grant access to Nomad workloads. | `string` | `"nomad-workload"` | no |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | The name of the role created and used by default for Nomad workload tokens. | `string` | `"nomad-workload"` | no |
| <a name="input_token_ttl"></a> [token\_ttl](#input\_token\_ttl) | The time-to-live value for tokens in seconds. | `number` | `3600` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_auth_backend_accessor"></a> [auth\_backend\_accessor](#output\_auth\_backend\_accessor) | The accessor of the JWT auth backend created. |
| <a name="output_auth_backend_path"></a> [auth\_backend\_path](#output\_auth\_backend\_path) | The path of the JWT auth backend created. |
| <a name="output_nomad_client_config"></a> [nomad\_client\_config](#output\_nomad\_client\_config) | A sample Vault configuration to be set in a Nomad client agent configuration file. |
| <a name="output_nomad_server_config"></a> [nomad\_server\_config](#output\_nomad\_server\_config) | A sample Vault configuration to be set in a Nomad server agent configuration file. |
| <a name="output_policy_name"></a> [policy\_name](#output\_policy\_name) | The name of the policy created. |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | The name of the role created. |

[nomad_wid]: https://developer.hashicorp.com/nomad/docs/concepts/workload-identity
