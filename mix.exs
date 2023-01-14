defmodule UeberauthMicrosoft.Mixfile do
  use Mix.Project

  @source_url "https://github.com/swelham/ueberauth_microsoft"
  @version "0.18.0"

  def project do
    [
      app: :ueberauth_microsoft,
      version: @version,
      elixir: "~> 1.4",
      package: package(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :ueberauth, :oauth2]
    ]
  end

  defp deps do
    [
      {:oauth2, "~> 1.0 or ~> 2.0"},
      {:ueberauth, "~> 0.7"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      name: :ueberauth_microsoft,
      description: "Microsoft Strategy for Überauth",
      maintainers: ["swelham"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url
      }
    ]
  end

  defp docs do
    [
      extras: [
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Overview"]
      ],
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      formatters: ["html"]
    ]
  end
end
