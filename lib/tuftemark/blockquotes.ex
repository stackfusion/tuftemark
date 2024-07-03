defmodule Tuftemark.Blockquotes do
  alias Earmark.{AstTools, Transform}

  def process(ast),
    do: Transform.map_ast(ast, &maybe_augment/1, true)

  defp maybe_augment({"blockquote", _, _, _} = node) do
    is_citation = not is_nil(AstTools.find_att_in_node(node, "cite"))
    is_epigraph = AstTools.find_att_in_node(node, "class", "") |> String.contains?("epigraph")

    cond do
      is_citation -> {:replace, to_citation(node)}
      is_epigraph -> {:replace, to_epigraph(node)}
      true -> node
    end
  end

  defp maybe_augment(node), do: node

  defp to_citation({"blockquote", attrs, children, meta} = node) do
    reversed_children = Enum.reverse(children)

    # we cannot guarantee that there will be a URL, but we assume so...
    cite_href = AstTools.find_att_in_node(node, "cite")

    new_children =
      case hd(reversed_children) do
        {"p", _, content, _} ->
          [blockquote_footer(cite_href, content) | tl(reversed_children)]

        _ ->
          [blockquote_footer(cite_href, cite_href) | reversed_children]
      end

    {"blockquote", attrs, Enum.reverse(new_children), meta}
  end

  defp to_epigraph({"blockquote", attrs, children, meta}) do
    reversed_children = Enum.reverse(children)

    {"p", _, footer_content, _} = hd(reversed_children)
    footer = {"footer", [], footer_content, %{}}

    new_attrs = Enum.reject(attrs, &(elem(&1, 0) == "class"))
    new_children = Enum.reverse([footer | tl(reversed_children)])

    blockquote = {"blockquote", new_attrs, new_children, meta}

    {"div", [{"class", "epigraph"}], [blockquote], %{}}
  end

  defp blockquote_footer(href, content) do
    anchor = {"a", [{"href", href}], List.wrap(content), %{}}

    {"footer", [], [anchor], %{}}
  end
end
