defmodule Ueberauth.Strategy.Microsoft do
  use Ueberauth.Strategy,
    default_scope: "https://graph.microsoft.com/user.read openid email offline_access",
    uid_field: :id

  alias OAuth2.{Response, Error}
  alias Ueberauth.Auth.{Info, Credentials, Extra}
  alias Ueberauth.Strategy.Microsoft.OAuth

  @doc """
  Handles initial request for Microsoft authentication.
  """
  def handle_request!(conn) do
    scopes = conn.params["scope"] || option(conn, :default_scope)

    params =
      [scope: scopes]
      |> with_scopes(:extra_scopes, conn)
      |> with_optional(:prompt, conn)
      |> with_state_param(conn)

    opts = oauth_client_options_from_conn(conn)
    redirect!(conn, Ueberauth.Strategy.Microsoft.OAuth.authorize_url!(params, opts))
  end

  @doc """
  Handles the callback from Microsoft.
  """
  def handle_callback!(%Plug.Conn{params: %{"code" => code}} = conn) do
    opts = conn |> options() |> Keyword.put(:redirect_uri, callback_url(conn))
    client = OAuth.get_token!([code: code], opts)
    token = client.token

    case token.access_token do
      nil ->
        err = token.other_params["error"]
        desc = token.other_params["error_description"]
        set_errors!(conn, [error(err, desc)])

      _token ->
        fetch_user(conn, client)
    end
  rescue
    err in [Error] ->
      set_errors!(conn, [error("OAuth2", err.reason)])
  end

  @doc false
  def handle_callback!(conn) do
    set_errors!(conn, [error("missing_code", "No code received")])
  end

  @doc false
  def handle_cleanup!(conn) do
    conn
    |> put_private(:ms_token, nil)
    |> put_private(:ms_user, nil)
  end

  def uid(conn) do
    user =
      conn
      |> option(:uid_field)
      |> to_string

    conn.private.ms_user[user]
  end

  def credentials(conn) do
    token = conn.private.ms_token
    scope_string = token.other_params["scope"] || ""
    scopes = String.split(scope_string, " ", trim: true)

    %Credentials{
      expires: token.expires_at != nil,
      expires_at: token.expires_at,
      scopes: scopes,
      token: token.access_token,
      refresh_token: token.refresh_token,
      token_type: token.token_type
    }
  end

  def info(conn) do
    user = conn.private.ms_user

    %Info{
      name: user["displayName"],
      email: user["mail"] || user["userPrincipalName"],
      first_name: user["givenName"],
      last_name: user["surname"]
    }
  end

  def extra(conn) do
    %Extra{
      raw_info: %{
        token: conn.private.ms_token,
        user: conn.private.ms_user
      }
    }
  end

  defp fetch_user(conn, client) do
    conn = put_private(conn, :ms_token, client.token)
    path = "https://graph.microsoft.com/v1.0/me/"

    case OAuth2.Client.get(client, path) do
      {:ok, %Response{status_code: 401}} ->
        set_errors!(conn, [error("token", "unauthorized")])

      {:ok, %Response{status_code: status, body: response}} when status in 200..299 ->
        put_private(conn, :ms_user, response)

      {:error, %Response{body: %{"error" => %{"code" => code, "message" => reason}}}} ->
        set_errors!(conn, [error(code, reason)])

      {:error, %Error{reason: reason}} ->
        set_errors!(conn, [error("OAuth2", reason)])
    end
  end

  defp with_optional(opts, key, conn) do
    if option(conn, key), do: Keyword.put(opts, key, option(conn, key)), else: opts
  end

  defp with_scopes(opts, key, conn) do
    if option(conn, key),
      do: Keyword.put(opts, :scope, "#{Keyword.get(opts, :scope, "")} #{option(conn, key)}"),
      else: opts
  end

  defp oauth_client_options_from_conn(conn) do
    base_options = [redirect_uri: callback_url(conn)]
    request_options = conn.private[:ueberauth_request_options].options

    request_options =
      Keyword.take(request_options, [
        :tenant_id,
        :client_id,
        :client_secret,
        :authorize_url,
        :token_url,
        :request_opts
      ])

    if nil in Keyword.values(request_options) do
      base_options
    else
      request_options ++ base_options
    end
  end

  defp option(conn, key) do
    default = Keyword.get(default_options(), key)

    conn
    |> options
    |> Keyword.get(key, default)
  end
end
