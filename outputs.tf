# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "auth_backend_accessor" {
  description = "The accessor of the JWT auth backend created."
  value       = vault_jwt_auth_backend.nomad.accessor
}

output "auth_backend_path" {
  description = "The path of the JWT auth backend created."
  value       = vault_jwt_auth_backend.nomad.path
}

output "role_name" {
  description = "The name of the role created."
  value       = vault_jwt_auth_backend_role.nomad_workload.role_name
}

output "policy_name" {
  description = "The name of the policy created."
  value       = vault_policy.nomad_workload.name
}

output "nomad_client_config" {
  description = "A sample Vault configuration to be set in a Nomad client agent configuration file."
  value       = <<EOF
vault {
  enabled               = true
  address               = "<Vault address>"
  jwt_auth_backend_path = "${vault_jwt_auth_backend.nomad.path}"
}
EOF
}

output "nomad_server_config" {
  description = "A sample Vault configuration to be set in a Nomad server agent configuration file."
  value       = <<EOF
vault {
  enabled = true

  default_identity {
    aud = ["${var.audience}"]
    ttl = "1h"
  }
}
EOF
}
