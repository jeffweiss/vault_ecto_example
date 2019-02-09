path "auth/approle/login" {
  capabilities = [ "create", "read" ]
}

path "database/creds/ecto" {
  capabilities = [ "read" ]
}
