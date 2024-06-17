defmodule Tuftemark do
  @moduledoc false

  alias Earmark.{Options, Parser, Transform}

  def as_html!(markdown, opts \\ []) do
    {:ok, ast, _warnings} = Parser.as_ast(markdown)

    options = Options.make_options!(opts)

    ast
    |> wrap_in("article")
    |> Transform.transform(options)
  end

  defp wrap_in(ast, tagname), do: [{tagname, [], ast, %{}}]
end
