# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "jwt_auth_path" {
  description = "The path to mount the JWT auth backend used by Nomad."
  type        = string
  default     = "jwt-nomad"
}

variable "role_name" {
  description = "The name of the role created and used by default for Nomad workload tokens."
  type        = string
  default     = "nomad-workload"
}

variable "policy_name" {
  description = "The name of the policy created and used to grant access to Nomad workloads."
  type        = string
  default     = "nomad-workload"
}

variable "nomad_jwks_url" {
  description = "The URL used by Vault to access Nomad's JWKS information."
  type        = string
}

variable "audience" {
  description = "The `aud` value set on Nomad workload identity JWTs."
  type        = string
  default     = "vault.io"
}

variable "token_ttl" {
  description = "The time-to-live value for tokens in seconds."
  type        = number
  default     = 3600
}
