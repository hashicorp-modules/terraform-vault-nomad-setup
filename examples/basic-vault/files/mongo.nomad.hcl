job "mongo" {
  group "db" {
    network {
      port "db" {
        to = 27017
      }
    }

    task "mongo" {
      driver = "docker"

      config {
        image = "mongo:7"
        ports = ["db"]
      }

      vault {}

      template {
        data        = <<EOF
MONGO_INITDB_ROOT_USERNAME=root
{{with secret "secret/data/default/mongo/config"}}
MONGO_INITDB_ROOT_PASSWORD={{.Data.data.root_password}}
{{end}}
EOF
        destination = "${NOMAD_SECRETS_DIR}/env"
        env         = true
      }
    }
  }
}
