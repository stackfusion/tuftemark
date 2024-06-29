defmodule Tuftemark do
  @moduledoc """
  Tuftemark converts Markdown content into format that is suitable to be used with Tufte CSS set of styles.

  Tufte CSS layout requires a few things to be applied to the HTML, for example:

  - the whole post must be wrapped in `<article>` tag
  - content must be split into `<section>`s around every H2 tag
  - footnotes must be converted into margin notes (compatible with the CSS)

  The `as_html!/2` method is trying to apply all the given transformation to the originally parsed AST,
  so we get applicable HTML output in the end.

  ## Extra Modifications

  Some of layout decisions cannot be made automatically, but we can use some super powers provided us by default
  Earmark's Parser.

  For example:

  - if we want a paragraph written in sans-serif, we can use Kramdown syntax for attributes: (`{:.sans}`);
  - if we want to provide a citation (as a blockquote), we can use set an attr: `{:cite="https://example.com"}`;

  See all such examples in the TuftemarkTest suite.
  """

  alias Earmark.{Options, Parser, Transform}
  alias Tuftemark.{Citations, Figures, Sections, Sidenotes, Utils}

  @doc """
  Expects a [GitHub Flavored Markdown](https://github.github.com/gfm/) as first argument and list of options
  applicable to [`Earmark.as_html!/2](https://hexdocs.pm/earmark/Earmark.html#as_html!/2) to pass into other
  Earmark-related modules.
  """
  def as_html!(markdown, opts \\ []) do
    {:ok, ast, _warnings} = Parser.as_ast(markdown)

    options = Options.make_options!(opts)

    ast
    |> Sidenotes.process()
    |> Citations.process()
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
