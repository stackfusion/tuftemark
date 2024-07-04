defmodule Tuftemark.Sidenotes do
  @moduledoc """
  Converts Markdown footnotes to HTML layout applicable to Tufte CSS.
  """

  alias Earmark.{Restructure, Transform}
  alias Tuftemark.Utils

  @parse_ex ~r/^\[\^(.*?)\]: (.*)/
  @split_ex ~r/\[\^(.*?)\]/

  def process(ast) do
    with {cleaner_ast, footnotes} <- find_footnotes(ast),
         sidenotes <- to_sidenotes(footnotes) do
      expand_footnotes(cleaner_ast, sidenotes)
    end
  end

  # Collects all footnote-paragraphs and removes them from the original AST
  defp find_footnotes(ast) do
    Restructure.walk_and_modify_ast(ast, %{}, fn
      {_, _, children, _} = node, footnotes_acc when children != [] ->
        # Some paragraphs start not with a text, but with an image or other tag
        # this is not what we're looking for here, we need only: `[^note]: ...`.
        #
        # So, (1) we take the first element and (2) check if it's a string, then
        # (3) we try to parse this piece of text; (4) if it can be parsed into
        # two parts, then it's likely a beginning of a footnote - we grab its
        # key and content (cleaned from the key).
        #
        # Then we re-combine all the details.
        #
        # If anything goes wrong: skip it and continue...
        with maybe_text <- hd(children),
             true <- is_binary(maybe_text),
             [key, content] <- parse_footnote(hd(children)) do
          footnote_children = [content | tl(children)]
          footnote = put_elem(node, 2, footnote_children)

          {[], Map.put(footnotes_acc, key, footnote)}
        else
          _ ->
            {node, footnotes_acc}
        end

      node, footnotes_acc ->
        {node, footnotes_acc}
    end)
  end

  # - Does it look like "[^note]: Lorem ipsum..."? Let's figure this out!
  defp parse_footnote(text),
    do: Regex.run(@parse_ex, text, capture: :all_but_first)

  # Converts footnote's layout into set of three tags
  defp to_sidenotes(footnotes) do
    footnotes
    |> Enum.map(fn {key, {_, attrs, children, meta}} ->
      is_numbered = String.starts_with?(key, "-")
      sidenote = Utils.sidenote(key, attrs, children, meta, is_numbered)

      {key, sidenote}
    end)
    |> Map.new()
  end

  # Eventually, we can process the previously cleaned AST, search for footnotes'
  # anchors inside the text nodes and replace them with elements from the stash
  # of the prepared sidenotes.
  #
  # We look into non-string nodes (the `true` last argument of the `map_ast/3`)
  # to avoid the issue when may get nested lists (`[[...]]`) for children. By
  # the way, that is why we `flatten` the resulting list of node's children in
  # the `maybe_expand/2` function.

  defp expand_footnotes(cleaner_ast, sidenotes),
    do: Transform.map_ast(cleaner_ast, &maybe_expand(&1, sidenotes), true)

  defp maybe_expand({tag, attrs, children, meta}, sidenotes) do
    new_children =
      children
      |> Enum.map(fn
        node when is_binary(node) ->
          node
          |> String.split(@split_ex, include_captures: true)
          |> Enum.map(&maybe_replace(&1, sidenotes))

        node ->
          node
      end)
      |> List.flatten()

    {:replace, {tag, attrs, new_children, meta}}
  end

  # Here we attempt to clean the sidenote key from what we got after splitting:
  # if we can parse "lorem-ipsum" from the given "[^lorem-ipsum]" then we try to
  # replace this piece with a sidenote elements, or skip trying...
  defp maybe_replace(piece, sidenotes) do
    case Regex.run(@split_ex, piece, capture: :all_but_first) do
      [sidenote_key] ->
        Map.get(sidenotes, sidenote_key, sidenote_key)

      _otherwise ->
        piece
    end
  end
end
