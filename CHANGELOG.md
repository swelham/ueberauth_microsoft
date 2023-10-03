## [0.23.0] - 2023-09-22

- [[#80](https://github.com/swelham/ueberauth_microsoft/pull/80)] - Add support for lc (locale) param in authorization URL ([@alejandrodevs](https://github.com/alejandrodevs))

## [0.22.0] - 2023-09-22

- [[#79](https://github.com/swelham/ueberauth_microsoft/pull/79)] - Add the option to get the client secret dynamically ([@alejandrodevs](https://github.com/alejandrodevs))

## [0.21.0] - 2023-07-07

- [[#72](https://github.com/swelham/ueberauth_microsoft/pull/72)] - Remove custom SSL options ([@arjan](https://github.com/arjan))

This change removes TLS 1.2 as the default ssl option in response to recent OTP changes. If you require TLS 1.2, you can specify this option in your `:ueberauth` config.

```elixir
config :ueberauth, Ueberauth.Strategy.Microsoft.OAuth,
  request_opts: [ssl_options: [versions: [:"tlsv1.2"]]]
```

## [0.20.0] - 2023-04-09

#### Dependencies

- [[#68](https://github.com/swelham/ueberauth_microsoft/pull/68)] Updated `ueberauth` from `0.10.3` to `0.10.5`.

## [0.19.0] - 2023-02-20

- [[#64](https://github.com/swelham/ueberauth_microsoft/pull/64)] Support loading config dynamically ([@docJerem](https://github.com/docJerem))
- [[#65](https://github.com/swelham/ueberauth_microsoft/pull/65)] Allow overriding the `prompt` option ([@trashhalo](https://github.com/trashhalo))

## [0.18.0] - 2023-01-14

#### Dependencies

- [[#62](https://github.com/swelham/ueberauth_microsoft/pull/62)] Updated `oauth2` from `2.0.1` to `2.1.0`.

## [0.17.0] - 2022-10-04

#### Dependencies

- [[#53](https://github.com/swelham/ueberauth_microsoft/pull/53)] Updated `oauth2` from `2.0.0` to `2.0.1`.
- [[#58](https://github.com/swelham/ueberauth_microsoft/pull/58)] Updated `ueberauth` from `0.7.0` to `0.10.3`.

## [0.16.0] - 2022-08-23

#### Enhancements

- [[#55](https://github.com/swelham/ueberauth_microsoft/pull/55)] Allow dynamic configs ([@ryanzidago](https://github.com/ryanzidago))

## [0.15.0] - 2022-04-06

#### :boom: Breaking Changes

- [[#48](https://github.com/swelham/ueberauth_microsoft/pull/48)] Parse scopes to match Ueberauth typespec ([@bismark](https://github.com/bismark))

This change updates the `Ueberauth.Auth.Credentials.scopes` attribute to a list of strings instead of a comma separated string. This aligns the attribute with the Ueberauth typespec and other Ueberauth strategies.

To migrate to this version, any code expecting `Credentials.scopes` to be a string will need to be updated to expect a list of strings.

```elixir
# Previous format
%Ueberauth.Auth{
  credentials: %Ueberauth.Auth.Credentials{
    scopes: "scope1,scope2",
    ...
  },
  ...
}

# New format
%Ueberauth.Auth{
  credentials: %Ueberauth.Auth.Credentials{
    scopes: ["scope1","scope2"],
    ...
  },
  ...
}
```
