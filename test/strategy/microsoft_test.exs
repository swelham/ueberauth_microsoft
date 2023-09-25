defmodule Ueberauth.Strategy.MicrosoftTest do
  use ExUnit.Case, async: true
  use Plug.Test

  test "lc param is present in the redirect uri" do
    conn = conn(:get, "/auth/microsoft", %{lc: 10})
    routes = Ueberauth.init()
    resp = Ueberauth.call(conn, routes)
    assert [location] = get_resp_header(resp, "location")
    redirect_uri = URI.parse(location)
    assert Plug.Conn.Query.decode(redirect_uri.query)["lc"] == "10"
  end
end
