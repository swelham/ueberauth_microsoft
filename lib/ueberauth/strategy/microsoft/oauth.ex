defmodule Ueberauth.Strategy.Microsoft.OAuth do
  use OAuth2.Strategy

  alias OAuth2.Client
  alias OAuth2.Strategy.AuthCode

  @defaults [
    strategy: __MODULE__,
    site: "https://graph.microsoft.com",
    authorize_url: "https://login.microsoftonline.com/common/oauth2/v2.0/authorize",
    token_url: "https://login.microsoftonline.com/common/oauth2/v2.0/token"
  ]

  def client(opts \\ []) do
    config = Application.get_env(:ueberauth, Ueberauth.Strategy.Microsoft.OAuth)

    @defaults
      |> Keyword.merge(config)
      |> Keyword.merge(opts)
      |> Client.new
  end

  def authorize_url!(params \\ [], opts \\ []) do
    opts
      |> client()
      |> Client.authorize_url!(params)
  end

  def get_token!(params \\ [], opts \\ []) do
    opts
      |> client()
      |> put_param(:client_secret, client().client_secret)
      |> Client.get_token!(params, [], opts ++ UeberauthMicrosoft.default_http_opts)
  end

  def authorize_url(client, params) do
    AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
      |> put_header("Accept", "application/json")
      |> AuthCode.get_token(params, headers)
  end
end