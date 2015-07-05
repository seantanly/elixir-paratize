defmodule Paratize.Mixfile do
  use Mix.Project

  @version "2.0.0"

  def project do
    [
      app: :paratize,
      version: @version,
      elixir: "~> 1.0",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps,
      package: package,
      docs: [source_ref: "v#{@version}", main: "overview"],
      name: "Paratize",
      source_url: "https://github.com/seantanly/elixir-paratize",
      homepage_url: "https://github.com/seantanly/elixir-paratize",
      description: """
      Elixir library providing some handy parallel processing facilities.
      """,
    ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.6", only: :dev},
    ]
  end

  defp package do
    [
      contributors: ["Sean Tan Li Yang"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/seantanly/elixir-paratize"},
      files: ~w(lib test) ++
             ~w(CHANGELOG.md LICENSE mix.exs README.md),
    ]
  end
end
