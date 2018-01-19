defmodule Paratize.Mixfile do
  use Mix.Project

  @version "2.1.5"

  def project do
    [
      app: :paratize,
      version: @version,
      elixir: "~> 1.1",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      package: package(),
      name: "Paratize",
      source_url: "https://github.com/seantanly/elixir-paratize",
      homepage_url: "https://github.com/seantanly/elixir-paratize",
      description: """
      Elixir library providing some handy parallel processing facilities.
      """,
      docs: docs()
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:credo, ">= 0.0.0", only: [:dev, :test]},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.16", only: [:dev], runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Sean Tan Li Yang"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/seantanly/elixir-paratize"},
      files: ~w(lib test) ++ ~w(mix.exs CHANGELOG.md LICENSE.md README.md)
    ]
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      main: "Paratize",
      # logo: "path/to/logo.png",
      extras: ~w(CHANGELOG.md LICENSE.md README.md)
    ]
  end

  defp aliases do
    [
      check: ["format --check-formatted --dry-run", "credo", "dialyzer"],
      "test.prod": ["check", &run_test/1]
    ]
  end

  defp run_test(_) do
    Mix.env(:test)
    Mix.Tasks.Test.run([])
  end
end
