defmodule Tuftemark.Utils do
  @moduledoc """
  Provides access to common helpers used in other parts of the Tuftemark convertor.
  """

  @doc """
  Wraps the given AST into another tag as a whole.

  ### Examples

      iex> ast = [{"p", [], ["Lorem ipsum"], %{}}]
      iex> Tuftemark.Utils.wrap_in(ast, "div")
      [{"div", [], [{"p", [], ["Lorem ipsum"], %{}}], %{}}]

  """
  def wrap_in(ast, tagname), do: [{tagname, [], ast, %{}}]
end
