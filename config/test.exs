import Config

config :ueberauth, Ueberauth,
  providers: [
    microsoft: {Ueberauth.Strategy.Microsoft, []}
  ]

config :ueberauth, Ueberauth.Strategy.Microsoft.OAuth,
  client_id: "client_id",
  client_secret: "client_secret"
