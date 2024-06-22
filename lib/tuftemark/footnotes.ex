defmodule Tuftemark.Footnotes do
  alias Earmark.{AstTools, Restructure, Transform}

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
        paragraph = hd(children)

        case Regex.run(~r/^\[\^(.+)\]: (.*)/, paragraph, capture: :all_but_first) do
          nil ->
            {item, acc}

          [note_id, note_clean] ->
            new_children = List.update_at(children, 0, fn _ -> note_clean end)
            new_item = put_elem(item, 2, new_children)

            {[], Map.put(acc, note_id, new_item)}
        end

      item, acc ->
        {item, acc}
    end)
  end

  # Convert footnote's layout (likely, from a `p` tag into set of three tags)
  defp convert(footnotes) do
    footnotes
    |> Enum.map(fn {key, {_, attrs, children, annotations}} ->
      label = {
        "label",
        [{"for", "sn-#{key}"}, {"class", "margin-toggle sidenote-number"}],
        [],
        %{}
      }

      input = {
        "input",
        [{"type", "checkbox"}, {"id", "sn-#{key}"}, {"class", "margin-toggle"}],
        [],
        %{}
      }

      footnote = {
        "span",
        AstTools.merge_atts(attrs, class: "sidenote"),
        children,
        annotations
      }

      {key, [label, input, footnote]}
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
