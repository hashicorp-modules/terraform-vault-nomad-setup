# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

locals {
  create_default_policy = length(var.policy_names) == 0
  policy_names          = local.create_default_policy ? vault_policy.nomad_workload[*].name : var.policy_names
}

# vault_jwt_auth_backend.nomad is the JWT auth method used by Nomad tasks to
# exchange their workload identity JSON Web Tokens (JWT) for Vault ACL tokens.
resource "vault_jwt_auth_backend" "nomad" {
  path               = var.jwt_auth_path
  description        = "JWT auth backend for Nomad"
  jwks_url           = var.nomad_jwks_url
  jwt_supported_algs = ["EdDSA"]

  # default_role is the role applied to tokens derived from this auth method
  # when no role is specified in the request.
  #
  # The final role value is determined from the following values, from highest
  # to lowest precedence:
  #   1. The "task.vault.role" field of the job.
  #   2. The "group.vault.role" field of the job.
  #   3. The "vault.create_from_role" configuration of the Nomad client running
  #      the task.
  #   4. This "default_role" value.
  default_role = var.role_name
}

# vault_jwt_auth_backend_role.nomad_workload is the ACL role applied to tokens
# generated by vault_jwt_auth_backend.nomad when the task doesn't request one.
resource "vault_jwt_auth_backend_role" "nomad_workload" {
  backend   = vault_jwt_auth_backend.nomad.path
  role_name = var.role_name
  role_type = "jwt"

  bound_audiences = [var.audience]

  # user_claim is used to uniquely identity a user in Vault by mapping tokens
  # to an entity alias.
  #
  # You must use the job ID in Vault Enterprise to comply with billing and
  # Terms of Service requirements.
  user_claim              = "/nomad_job_id"
  user_claim_json_pointer = true

  claim_mappings = {
    nomad_namespace = "nomad_namespace"
    nomad_job_id    = "nomad_job_id"
    nomad_group     = "nomad_group"
    nomad_task      = "nomad_task"
  }

  # token_type should be "service" so Nomad can renew them throughout the
  # task's lifecycle. Tokens of type "batch" cannot be renewed and may result
  # in errors if the task outlives the token TTL and tries to access Vault.
  token_type     = "service"
  token_policies = local.policy_names
  token_ttl      = var.token_ttl

  # token_explicit_max_ttl must be 0 so Nomad can renew tokens for as long as
  # the task runs.
  token_explicit_max_ttl = 0
}

# vault_policy.nomad_workload is a sample ACL policy that grants tasks read
# access to secrets in the path "secret/<job namespace>/<job ID>/*" to
# illustrate how policies can reference values from the claim_mappings defined
# in vault_jwt_auth_backend_role.nomad_workload.
#
# Refer to the Vault documentation for more information on templated ACL
# policies.
# https://developer.hashicorp.com/vault/tutorials/policies/policy-templating#create-templated-acl-policies
#
# This is the policy used in vault_jwt_auth_backend_role.nomad_workload if the
# variable policy_names is not set.
resource "vault_policy" "nomad_workload" {
  count = local.create_default_policy ? 1 : 0

  name   = var.default_policy_name
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
