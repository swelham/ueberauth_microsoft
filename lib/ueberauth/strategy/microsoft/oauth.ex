defmodule Ueberauth.Strategy.Microsoft.OAuth do
  use OAuth2.Strategy

  alias Ueberauth
  alias OAuth2.Client
  alias OAuth2.Strategy.AuthCode
  alias OAuth2.Strategy.Refresh

  def client(opts \\ []) do
    config = Application.get_env(:ueberauth, __MODULE__)
    json_library = Ueberauth.json_library()

    config
    |> defaults()
    |> Keyword.merge(config)
    |> Keyword.merge(opts)
    |> Client.new()
    |> OAuth2.Client.put_serializer("application/json", json_library)
  end

  def refresh_client(opts \\ []) do
    config = Application.get_env(:ueberauth, __MODULE__)
    json_library = Ueberauth.json_library()
    defaults = defaults(config)

    config
    |> defaults()
    |> Keyword.merge(config)
    |> Keyword.put(:token_url, Keyword.get(defaults, :refresh_token_url))
    |> Keyword.put(:token_method, :post)
    |> Keyword.merge(opts)
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

  def refresh_token!(params \\ [], opts \\ []) do
    opts ++ [token: %OAuth2.AccessToken{refresh_token: params[:refresh_token]}]
    |> client
    |> Client.refresh_token!(params)
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

  def refresh_token(client, params, headers) do
    client
    |> put_param(:client_id, client.client_id)
    |> put_param(:client_secret, client.client_secret)
    |> Refresh.get_token(params, headers)
  end

  defp defaults(config) do
    tenant_id = config[:tenant_id] || "common"

    [
      strategy: __MODULE__,
      site: "https://login.microsoftonline.com/#{tenant_id}/oauth2/v2.0",
      authorize_url: "https://login.microsoftonline.com/#{tenant_id}/oauth2/v2.0/authorize",
      token_url: "/token",
      request_opts: [ssl_options: [versions: [:"tlsv1.2"]]]
    ]
  end
end
