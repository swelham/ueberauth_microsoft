# Überauth Microsoft

[![Module Version](https://img.shields.io/hexpm/v/ueberauth_microsoft.svg)](https://hex.pm/packages/ueberauth_microsoft)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/ueberauth_microsoft/)
[![License](https://img.shields.io/hexpm/l/ueberauth_microsoft.svg)](https://github.com/swelham/ueberauth_microsoft/blob/master/LICENSE.md)
[![Last Updated](https://img.shields.io/github/last-commit/swelham/ueberauth_microsoft.svg)](https://github.com/swelham/ueberauth_microsoft/commits/master)

> Microsoft OAuth2 strategy for Überauth.

Quick start blog post: [Authenticating users with Microsoft OAuth](https://www.stuartwelham.com/articles/authenticating-users-with-microsoft-oauth)

## Installation

1.  Register an application in the Azure Portal ([see Microsoft tutorial for more info](https://learn.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app)).

2.  Add `:ueberauth_microsoft` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [
        {:ueberauth_microsoft, "~> 0.23"}
      ]
    end
    ```

3.  Add the strategy to your applications:

    ```elixir
    def application do
      [
        applications: [:ueberauth_microsoft]
      ]
    end
    ```

4.  Add Microsoft to your Überauth configuration:

    ```elixir
    config :ueberauth, Ueberauth,
      providers: [
        microsoft: {Ueberauth.Strategy.Microsoft, []}
      ]
    ```

5.  Update your provider configuration:

    ```elixir
    config :ueberauth, Ueberauth.Strategy.Microsoft.OAuth,
      client_id: System.get_env("MICROSOFT_CLIENT_ID"),
      client_secret: System.get_env("MICROSOFT_CLIENT_SECRET")
    ```

6.  Include the Überauth plug in your controller:

    ```elixir
    defmodule MyApp.AuthController do
      use MyApp.Web, :controller
      plug Ueberauth
      ...
    end
    ```

7.  Create the request and callback routes if you haven't already:

    ```elixir
    scope "/auth", MyApp do
      pipe_through :browser

      get "/:provider", AuthController, :request
      get "/:provider/callback", AuthController, :callback
    end
    ```

8.  Your controller needs to implement callbacks to deal with `Ueberauth.Auth`
    and `Ueberauth.Failure` responses.

For an example implementation see the [Überauth Example](https://github.com/ueberauth/ueberauth_example) application.

## Single Tenancy

If you are going to use your app only internally you may need to configure it for a single tenant.
To do so you only need to add `tenant_id` to your provider configuration like:

```elixir
config :ueberauth, Ueberauth.Strategy.Microsoft.OAuth,
  tenant_id: System.get_env("MICROSOFT_TENANT_ID"),
  client_id: System.get_env("MICROSOFT_CLIENT_ID"),
  client_secret: System.get_env("MICROSOFT_CLIENT_SECRET")
```

## Calling

Depending on the configured url you can initial the request through:

    /auth/microsoft

By default the scopes used are:

- openid
- email
- offline_access
- https://graph.microsoft.com/user.read

_Note: at least one service scope is required in order for a token to be
returned by the Microsoft endpoint_

You can configure additional scopes to be used by passing the `extra_scopes`
option into the provider:

```elixir
config :ueberauth, Ueberauth,
  providers: [
    microsoft: {
      Ueberauth.Strategy.Microsoft,
      [extra_scopes: "https://graph.microsoft.com/calendars.read"]
    }
  ]
```

If you would like users to have the option to choose an alternate account to authenticate with instead of defaulting to the logged in account, you may pass the `prompt` option in to the provider (per [Microsoft documentation](https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-auth-code-flow)):

```elixir
config :ueberauth, Ueberauth,
  providers: [
    microsoft: {Ueberauth.Strategy.Microsoft, [prompt: "select_account"]}
  ]
```

## Copyright and License

Copyright (c) 2017 Stuart Welham

Released under the MIT License, which can be found in the repository in
[LICENSE](./LICENSE.md).
