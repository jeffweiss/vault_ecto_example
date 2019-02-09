defmodule Sample.Repo do
  use Ecto.Repo,
    otp_app: :sample,
    adapter: Ecto.Adapters.Postgres

  def init(type, config) do
    # hack for ecto mix tasks
    if (type == :runtime) do
      Application.ensure_all_started(:hackney)
      Application.ensure_all_started(:tesla)
    end

    vault_config = Application.get_env(:sample, :vault)
    host = Keyword.get(vault_config, :addr) || System.get_env("VAULT_ADDR")

    [role_id, secret_id] = get_vault_credentials()

    {:ok, vault} =
      Vault.new(%{host: host, auth: Vault.Auth.Approle}) |> Vault.auth(%{role_id: role_id, secret_id: secret_id})

    {:ok, values} = Vault.read(vault, "database/creds/ecto")
    {:ok, Keyword.merge(config, username: values["username"], password: values["password"])}
  end

  defp get_vault_credentials do
    app_dir = Application.app_dir(:sample, "priv/credentials")

    ["role_id", "secret_id"]
    |> Enum.map(fn type ->
      app_dir
      |> Path.join("#{type}.json")
      |> File.read!()
      |> Jason.decode!()
      |> Map.get("data")
      |> Map.get(type)
    end)
  end
end
