# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "vault_jwt_auth_backend" "nomad" {
  path               = var.jwt_auth_path
  description        = "JWT auth backend for Nomad"
  jwks_url           = var.nomad_jwks_url
  jwt_supported_algs = ["EdDSA"]
  default_role       = var.role_name
}

resource "vault_jwt_auth_backend_role" "nomad_workload" {
  backend   = vault_jwt_auth_backend.nomad.path
  role_name = var.role_name
  role_type = "jwt"

  bound_audiences = [var.audience]

  user_claim              = "/nomad_job_id"
  user_claim_json_pointer = true

  claim_mappings = {
    nomad_namespace = "nomad_namespace"
    nomad_job_id    = "nomad_job_id"
    nomad_group     = "nomad_group"
    nomad_task      = "nomad_task"
  }

  token_type             = "service"
  token_policies         = [vault_policy.nomad_workload.name]
  token_ttl              = var.token_ttl
  token_explicit_max_ttl = 0
}

resource "vault_policy" "nomad_workload" {
  name   = var.policy_name
  policy = <<EOT
path "secret/data/{{identity.entity.aliases.${vault_jwt_auth_backend.nomad.accessor}.metadata.nomad_namespace}}/{{identity.entity.aliases.${vault_jwt_auth_backend.nomad.accessor}.metadata.nomad_job_id}}/*" {
  capabilities = ["read"]
}

path "secret/data/{{identity.entity.aliases.${vault_jwt_auth_backend.nomad.accessor}.metadata.nomad_namespace}}/{{identity.entity.aliases.${vault_jwt_auth_backend.nomad.accessor}.metadata.nomad_job_id}}" {
  capabilities = ["read"]
}

path "secret/metadata/{{identity.entity.aliases.${vault_jwt_auth_backend.nomad.accessor}.metadata.nomad_namespace}}/*" {
  capabilities = ["list"]
}

path "secret/metadata/*" {
  capabilities = ["list"]
}
EOT
}
