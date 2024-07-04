defmodule Tuftemark.MixProject do
  use Mix.Project

  @version "0.2.0"
  @url "https://github.com/stackfusion/tuftemark"

  def project do
    [
      app: :tuftemark,
      deps: deps(),
      description:
        "Markdown converter tailored for Edward Tufte's handout format and ready to be used with Tufte CSS",
      docs: docs(),
      elixir: "~> 1.16",
      name: "Tuftemark",
      package: package(),
      version: @version
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:earmark, "~> 1.4"},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "Tuftemark",
      source_ref: "v#{@version}",
      source_url: @url
    ]
  end

  defp package do
    %{
      licenses: ["MIT"],
      maintainers: ["Sergey Kuznetsov"],
      links: %{"GitHub" => @url}
    }
  end
end
