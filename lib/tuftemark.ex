defmodule Tuftemark do
  @moduledoc false

  alias Earmark.{Options, Parser, Transform}

  def as_html!(markdown, opts \\ []) do
    {:ok, ast, _warnings} = Parser.as_ast(markdown)

    options = Options.make_options!(opts)

    ast
    |> wrap_in_article()
    |> Transform.transform(options)
  end

  # We must wrap the whole document in the article tag
  defp wrap_in_article(ast), do: [{"article", [], ast, %{}}]
end
