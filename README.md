# Überauth Microsoft

> Microsoft OAuth2 strategy for Überauth.

## Installation

1. Setup your application at the new [Microsoft app registration portal](https://apps.dev.microsoft.com).

1. Add `:ueberauth_microsoft` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:ueberauth_microsoft, "~> 0.6"}]
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

## License

Please see [LICENSE](https://github.com/ueberauth/ueberauth_microsoft/blob/master/LICENSE) for licensing details.
