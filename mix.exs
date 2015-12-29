defmodule WeatherXML.Mixfile do
  use Mix.Project

  def project do
    [app: :weather_xml,
     version: "0.0.1",
     elixir: "~> 1.1",
     escript: escript_config,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger, :httpoison]]
  end

  defp deps do
    [
      { :httpoison, "~> 0.4" },
      { :ex_doc,    github: "elixir-lang/ex_doc" },
      { :earmark,    ">= 0.0.0" }
    ]
  end

  defp escript_config do
    [main_module: WeatherXML.CLI]
  end
end
