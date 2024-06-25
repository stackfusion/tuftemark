defmodule Tuftemark.Sections do
  @moduledoc """
  Split the given AST into sections (by wrapping corresponding pieces of content) around each `h2` tag.
  """

  alias Earmark.Restructure
  alias Tuftemark.Utils

  def process(ast) do
    ast
    |> Restructure.walk_and_modify_ast([], &make_section/2)
    |> last_section()
  end

  defp make_section({"h2", _, _, _} = item, acc),
    do: {acc |> Enum.reverse() |> Utils.wrap_in("section"), [item]}

  defp make_section(item, acc),
    do: {[], [item | acc]}

  defp last_section({ast, acc}),
    do: ast ++ Utils.wrap_in(Enum.reverse(acc), "section")
end
