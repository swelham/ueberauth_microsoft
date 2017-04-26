defmodule Ueberauth.Strategy.Microsoft do
  use Ueberauth.Strategy, default_scope: "https://graph.microsoft.com/user.read openid email offline_access",
                          uid_field: :id
                      
  alias OAuth2.{Response, Error, AccessToken}
  alias Ueberauth.Auth.{Info, Credentials, Extra}
  alias Ueberauth.Strategy.Microsoft.OAuth

  @doc """
  Handles initial request for Microsoft authentication.
  """
  def handle_request!(conn) do
    default_scopes = option(conn, :default_scope)
    extra_scopes = option(conn, :extra_scopes)
    
    scopes = "#{extra_scopes} #{default_scopes}"

    authorize_url =
      conn.params
      #|> put_param(conn, "scope", :default_scope)
      |> Map.put(:scope, scopes)
      |> Map.put(:redirect_uri, callback_url(conn))
      |> OAuth.authorize_url!

    redirect!(conn, authorize_url)
  end

  @doc """
  Handles the callback from Microsoft.
  """
  def handle_callback!(%Plug.Conn{params: %{"code" => code}} = conn) do
    opts = [redirect_uri: callback_url(conn)]
    client = OAuth.get_token!([code: code], opts)
    
    case client.access_token do
      nil ->
        err = client.other_params["error"]
        desc = client.other_params["error_description"]
        set_errors!(conn, [error(err, desc)])
      _token ->
        fetch_user(conn, client)
    end
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
    user = conn
      |> option(:uid_field)
      |> to_string

    conn.private.ms_user[user]
  end

  def credentials(conn) do
    token = conn.private.ms_token

    %Credentials{
      expires: token.expires_at != nil,
      expires_at: token.expires_at,
      scopes: token.other_params["scope"],
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

  defp fetch_user(conn, token) do
    conn = put_private(conn, :ms_token, token)
    path = "https://graph.microsoft.com/v1.0/me/"

    case AccessToken.get(token, path, [], UeberauthMicrosoft.default_http_opts) do
      {:ok, %Response{status_code: 401}} ->
        set_errors!(conn, [error("token", "unauthorized")])
      {:ok, %Response{status_code: 200, body: response}} ->
          put_private(conn, :ms_user, response)
      {:error, %Error{reason: reason}} ->
        set_errors!(conn, [error("OAuth2", reason)])
    end
  end
  
  defp option(conn, key) do
    default = Keyword.get(default_options(), key)

    conn
      |> options
      |> Keyword.get(key, default)
  end
end