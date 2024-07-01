defmodule Tuftemark do
  @external_resource "README.md"
  @moduledoc "README.md" |> File.read!() |> String.split("<!-- MDOC !-->") |> Enum.fetch!(1)

  alias Earmark.{Options, Parser, Transform}
  alias Tuftemark.{Blockquotes, Figures, Sections, Sidenotes, Utils}

  @doc """
  Expects a [GitHub Flavored Markdown](https://github.github.com/gfm/) as first argument and list of options
  applicable to [`Earmark.as_html!/2`](https://hexdocs.pm/earmark/Earmark.html#as_html!/2) to pass into other
  Earmark-related modules.
  """
  def as_html!(markdown, opts \\ []) do
    {:ok, ast, _warnings} = Parser.as_ast(markdown)

    options = Options.make_options!(opts)

    ast
    |> Sidenotes.process()
    |> Blockquotes.process()
    |> Figures.process()
    |> Sections.process()
    |> Utils.wrap_in("article")
    |> Transform.transform(options)
  end

  @doc """
  Processes files on a disk, converts Markdown to HTML using `as_html!/2`.

  ## Usage Example

  ```console
  mix run -e "Tuftemark.convert!()" -- example.md example.html
  ```
  """
  def convert!() do
    [input_file, output_file] = System.argv()

    html_content = input_file |> File.read!() |> as_html!(compact_output: true)

    html_full = """
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="utf-8"/>
        <title>Tufte CSS</title>
        <link rel="stylesheet" href="tufte.css"/>
        <meta name="viewport" content="width=device-width, initial-scale=1">
      </head>
      <body>
        #{html_content}
      </body>
    </html>
    """

    File.write!(output_file, html_full)
  end
end
