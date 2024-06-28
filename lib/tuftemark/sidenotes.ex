defmodule Tuftemark.Sidenotes do
  alias Earmark.{Restructure, Transform}
  alias Tuftemark.Utils

  def process(ast) do
    with {cleaner_ast, footnotes} <- find_and_clean(ast),
         converted_footnotes <- convert(footnotes) do
      modify(cleaner_ast, converted_footnotes)
    end
  end

  # Collect all paragraph-footnotes and remove them from the original AST
  defp find_and_clean(ast) do
    Restructure.walk_and_modify_ast(ast, %{}, fn
      {"p", _, children, _} = item, acc ->
        # some paragraphs start not with a text, but with an image or other tag
        # this is not what we're looking for here, we need only: `[^note]: ...`
        with maybe_text <- hd(children),
             true <- is_binary(maybe_text),
             [note_id, note_clean] <-
               Regex.run(~r/^\[\^(.+)\]: (.*)/, maybe_text, capture: :all_but_first) do
          new_children = List.update_at(children, 0, fn _ -> note_clean end)
          new_item = put_elem(item, 2, new_children)

          {[], Map.put(acc, note_id, new_item)}
        else
          _ -> {item, acc}
        end

      item, acc ->
        {item, acc}
    end)
  end

  # Convert footnote's layout (likely, from a `p` tag into set of three tags)
  defp convert(footnotes) do
    footnotes
    |> Enum.map(fn {key, {_, attrs, children, annotations}} ->
      is_numbered = String.starts_with?(key, "-")
      sidenote = Utils.sidenote(key, attrs, children, annotations, is_numbered)

      {key, sidenote}
    end)
    |> Enum.into(%{})
  end

  # Eventually, we can postprocess previously cleaned AST, find footnotes in its items
  # and replace them with ones from the map of converted footnotes.
  defp modify(cleaner_ast, footnotes_found) do
    Transform.map_ast(cleaner_ast, fn
      item when is_binary(item) ->
        item
        |> String.split(~r/\[\^(.+)\]/, include_captures: true)
        |> Enum.map(fn piece ->
          case Regex.run(~r/^\[\^(.+)\]/, piece, capture: :all_but_first) do
            [footnote_key] ->
              # if we cannot find a footnote in the given map (due to a
              # possible TYPO), we won't replace it
              Map.get(footnotes_found, footnote_key, piece)

            _otherwise ->
              piece
          end
        end)

      item ->
        item
    end)
  end
end
