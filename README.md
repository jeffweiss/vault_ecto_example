# Vault-Ecto Sample

## Overview

This repo is to keep track of the latest state of using Hashicorp Vault for as
the source of short-term credentials to a Postgres database that is then used by
Ecto in an Elixir application.

## Components

### docker-compose.yml

The easiest way to ensure consistent environment for both Vault and Postgres is
to create a Docker network and containers for both.

### Bootstrap Configuration Scripts

We need to bootstrap Vault to 1) connect to Postgres, 2) issue short-lived
credentials, 3) revoke credentials. The standard Hashicorp Vault docs have
[instructions](https://learn.hashicorp.com/vault/developer/sm-dynamic-secrets)
but, here, we're just interested in ensuring it's configured.

### Sample Elixir + Ecto Application

We need a test bed for experimenting with Ecto using the limited credentials
issued by Vault.

## Latest state of Ecto/Vault readiness

### `ecto.create`

Since we're given a temporary username and password, and we want to ensure the
database is accessible each time, we should pre-create the database rather than
using `mix ecto.create` to do so. Later runs of `mix ecto.create` should
indicate that the database is already created.

### `ecto.drop`

Since we have a temporary username and password, we don't want it to have
permissions to drop the database. Deleting the database should be a deliberate
action outside of our application. Running `mix ecto.drop` should fail.

### `ecto.migrate`

Not yet tested.

### `Repo.init/2`

We have to talk to Vault in the `Repo.init/2` to get the temporary credentials.
We currently have a hack in place to ensure that when we run the Ecto mix tasks
that the necessary dependencies are started to ensure we _can_ talk to Vault.

### connection pool

We have some issues here. We don't have a clean way drain the connection pool,
re-retrive the configuration from `Repo.init/2`, and then spin the connection
pool back up. Early evidence indicates the connections can stay live past the
password expiration, but the pool worker will fail when it attempts to reconnect
and will never re-request its configuration.

## Running

Set up the Vault and Postgres environments with

    bin/setup


