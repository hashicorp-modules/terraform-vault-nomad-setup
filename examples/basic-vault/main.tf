module "vault_setup" {
  source = "./../.."

  nomad_jwks_url = "http://localhost:4646/.well-known/jwks.json"
}

# Create Vault secret the job needs.
resource "vault_kv_secret_v2" "mongo" {
  mount = "secret"
  name  = "default/mongo/config"

  data_json = jsonencode({
    root_password = "super-secret"
  })
}

# Register Nomad job.
resource "nomad_job" "workload_identity_demo" {
  depends_on = [
    module.vault_setup,
    vault_kv_secret_v2.mongo,
  ]

  jobspec = file("${path.module}/files/mongo.nomad.hcl")
  detach  = false
}
