defmodule Ueberauth.Strategy.Microsoft.OAuth do
  use OAuth2.Strategy

  alias Ueberauth
  alias OAuth2.Client
  alias OAuth2.Strategy.AuthCode

  def client(opts \\ []) do
    config = Application.get_env(:ueberauth, __MODULE__, [])
    json_library = Ueberauth.json_library()

    config
    |> defaults()
    |> Keyword.merge(config)
    |> Keyword.merge(opts)
    |> generate_secret()
    |> Client.new()
    |> OAuth2.Client.put_serializer("application/json", json_library)
  end

  def authorize_url!(params \\ [], opts \\ []) do
    opts
    |> client
    |> Client.authorize_url!(params)
  end

  def get_token!(params \\ [], opts \\ []) do
    opts
    |> client
    |> Client.get_token!(params)
  end

  # oauth2 Strategy Callbacks

  def authorize_url(client, params) do
    AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_param(:client_secret, client.client_secret)
    |> put_header("Accept", "application/json")
    |> AuthCode.get_token(params, headers)
  end

  defp defaults(config) do
    tenant_id = config[:tenant_id] || "common"

    [
      strategy: __MODULE__,
      site: "https://graph.microsoft.com",
      authorize_url: "https://login.microsoftonline.com/#{tenant_id}/oauth2/v2.0/authorize",
      token_url: "https://login.microsoftonline.com/#{tenant_id}/oauth2/v2.0/token"
    ]
  end

  defp generate_secret(opts) do
    if is_tuple(opts[:client_secret]) do
      {module, fun} = opts[:client_secret]
      secret = apply(module, fun, [opts])
      Keyword.put(opts, :client_secret, secret)
    else
      opts
    end
  end
end
