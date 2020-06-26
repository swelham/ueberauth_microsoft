# Überauth Microsoft

> Microsoft OAuth2 strategy for Überauth.

## Installation

1. Setup your application at the new [Microsoft app registration portal](https://apps.dev.microsoft.com).

1. Add `:ueberauth_microsoft` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:ueberauth_microsoft, "~> 0.7"}]
    end
    ```

2. Add the strategy to your applications:

    ```elixir
    def application do
      [applications: [:ueberauth_microsoft]]
    end
    ```

3. Add Microsoft to your Überauth configuration:

    ```elixir
    config :ueberauth, Ueberauth,
      providers: [
        microsoft: {Ueberauth.Strategy.Microsoft, []}
      ]
    ```

4.  Update your provider configuration:

    ```elixir
    config :ueberauth, Ueberauth.Strategy.Microsoft.OAuth,
      client_id: System.get_env("MICROSOFT_CLIENT_ID"),
      client_secret: System.get_env("MICROSOFT_CLIENT_SECRET")
    ```

5.  Include the Überauth plug in your controller:

    ```elixir
    defmodule MyApp.AuthController do
      use MyApp.Web, :controller
      plug Ueberauth
      ...
    end
    ```

6.  Create the request and callback routes if you haven't already:

    ```elixir
    scope "/auth", MyApp do
      pipe_through :browser

      get "/:provider", AuthController, :request
      get "/:provider/callback", AuthController, :callback
    end
    ```

7. Your controller needs to implement callbacks to deal with `Ueberauth.Auth` and `Ueberauth.Failure` responses.

For an example implementation see the [Überauth Example](https://github.com/ueberauth/ueberauth_example) application.

## Single Tenancy

If you are going to use your app only internally you may need to configure it for a single tenant.
To do so you only need to add `tenant_id` to your provider configuration like:
  ```
  config :ueberauth, Ueberauth.Strategy.Microsoft.OAuth,
    tenant_id: System.get_env("MICROSOFT_TENANT_ID"),
    client_id: System.get_env("MICROSOFT_CLIENT_ID"),
    client_secret: System.get_env("MICROSOFT_CLIENT_SECRET")
  ```

## Calling

Depending on the configured url you can initial the request through:

    /auth/microsoft

By default the scopes used are
* openid
* email
* offline_access
* https://graph.microsoft.com/user.read

*Note: at least one service scope is required in order for a token to be returned by the Microsoft endpoint*

You can configure additional scopes to be used by passing the `extra_scopes` option into the provider

```elixir
config :ueberauth, Ueberauth,
  providers: [
    microsoft: {Ueberauth.Strategy.Microsoft, [extra_scopes: "https://graph.microsoft.com/calendars.read"]}
  ]
```

## Refreshing Tokens

Depending on your requirements, it may be necessary to get a new access code after expiry.
To do so, you need to persist the `refresh_token` and use it later to get a new access code like:
  ```elixir
  refresh_token = Token.get_refresh_token()

  Ueberauth.Strategy.Microsoft.OAuth.refresh_token!(refresh_token: refresh_token)
  ```
 
## License

Please see [LICENSE](https://github.com/ueberauth/ueberauth_microsoft/blob/master/LICENSE) for licensing details.
