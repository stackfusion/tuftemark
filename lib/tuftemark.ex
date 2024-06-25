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

  alias Earmark.{Options, Parser, Restructure, Transform}
  alias Tuftemark.{Citations, Footnotes, Utils}

  @doc """
  Expects a [GitHub Flavored Markdown](https://github.github.com/gfm/) as first argument and list of options
  applicable to [`Earmark.as_html!/2](https://hexdocs.pm/earmark/Earmark.html#as_html!/2) to pass into other
  Earmark-related modules.
  """
  def as_html!(markdown, opts \\ []) do
    {:ok, ast, _warnings} = Parser.as_ast(markdown)

    options = Options.make_options!(opts)

    ast
    |> Footnotes.process()
    |> Citations.process()
    |> Restructure.walk_and_modify_ast([], &make_section/2)
    |> last_section()
    |> Utils.wrap_in("article")
    |> Transform.transform(options)
  end

  defp make_section({"h2", _, _, _} = item, acc),
    do: {Utils.wrap_in(Enum.reverse(acc), "section"), [item]}

  defp make_section(item, acc),
    do: {[], [item | acc]}

  defp last_section({ast, acc}),
    do: ast ++ Utils.wrap_in(Enum.reverse(acc), "section")
end
