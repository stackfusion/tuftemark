defmodule Tuftemark.Blockquotes do
  alias Earmark.{AstTools, Restructure}

  def process(ast) do
    ast
    |> Restructure.walk_and_modify_ast([], &find_and_replace/2)
    |> elem(0)
  end

  defp find_and_replace({"blockquote", _, _, _} = item, acc) do
    is_citation = not is_nil(AstTools.find_att_in_node(item, "cite"))
    is_epigraph = AstTools.find_att_in_node(item, "class", "") |> String.contains?("epigraph")

    cond do
      is_citation -> {to_citation(item), acc}
      is_epigraph -> {to_epigraph(item), acc}
      true -> {item, acc}
    end
  end

  defp find_and_replace(item, acc), do: {item, acc}

  defp to_citation({"blockquote", attrs, children, annotations} = item) do
    reversed_children = Enum.reverse(children)

    # of course, we cannot guarantee that there will be a URL, but we assume so...
    cite_href = AstTools.find_att_in_node(item, "cite")

    new_children =
      case hd(reversed_children) do
        {"p", _, content, _} ->
          [blockquote_footer(cite_href, content) | tl(reversed_children)]

        _ ->
          [blockquote_footer(cite_href, cite_href) | reversed_children]
      end

    {"blockquote", attrs, Enum.reverse(new_children), annotations}
  end

  defp to_epigraph({"blockquote", attrs, children, annotations}) do
    reversed_children = Enum.reverse(children)

    {"p", _, footer_content, _} = hd(reversed_children)
    footer = {"footer", [], footer_content, %{}}

    new_attrs = Enum.reject(attrs, &(elem(&1, 0) == "class"))
    new_children = Enum.reverse([footer | tl(reversed_children)])

    blockquote = {"blockquote", new_attrs, new_children, annotations}

    {"div", [{"class", "epigraph"}], [blockquote], %{}}
  end

  defp blockquote_footer(href, content) do
    anchor = {"a", [{"href", href}], List.wrap(content), %{}}

    {"footer", [], [anchor], %{}}
  end
end
