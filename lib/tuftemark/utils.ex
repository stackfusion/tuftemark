defmodule Tuftemark.Utils do
  @moduledoc """
  Provides access to common helpers used in other parts of the Tuftemark convertor.
  """

  alias Earmark.AstTools

  @doc """
  Wraps the given AST into another tag as a whole.

  ### Examples

      iex> ast = [{"p", [], ["Lorem ipsum"], %{}}]
      iex> Tuftemark.Utils.wrap_in(ast, "div")
      [{"div", [], [{"p", [], ["Lorem ipsum"], %{}}], %{}}]

  """
  def wrap_in(ast, tagname), do: [{tagname, [], ast, %{}}]

  @doc """
  Generates a set of tags (with proper classes set) to be used as side- or
  marginal note.

  The main difference is that for sidenotes we must pass truthy `is_numbered`
  to get automatic numbering for them. Marginal notes shall not be numbered.
  """
  def sidenote(key, attrs, children, meta, is_numbered \\ false) do
    {for_attr, label_class, label_anchor, note_class} =
      if is_numbered do
        {"sn-#{key}", "margin-toggle sidenote-number", "", "sidenote"}
      else
        {"mn-#{key}", "margin-toggle", "⊕", "marginnote"}
      end

    label =
      {"label", [{"for", for_attr}, {"class", label_class}], [label_anchor], %{}}

    input =
      {"input", [{"type", "checkbox"}, {"id", for_attr}, {"class", "margin-toggle"}], [], %{}}

    note =
      {"span", AstTools.merge_atts(attrs, class: note_class), List.wrap(children), meta}

    [label, input, note]
  end
end
