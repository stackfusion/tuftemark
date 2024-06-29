defmodule Tuftemark.Blockquotes do
  alias Earmark.Restructure

  def process(ast) do
    ast
    |> Restructure.walk_and_modify_ast([], &find_and_replace/2)
    |> elem(0)
  end

  defp find_and_replace({"blockquote", attrs, children, annotations} = item, acc) do
    case Enum.find(attrs, &(elem(&1, 0) == "cite" || elem(&1, 0) == "role")) do
      {"cite", href} ->
        {citation(href, attrs, children, annotations), acc}

      {"role", "epigraph"} ->
        {epigraph(attrs, children, annotations), acc}

      _otherwise ->
        {item, acc}
    end
  end

  defp find_and_replace(item, acc), do: {item, acc}

  defp citation(href, attrs, children, annotations) do
    reversed_children = Enum.reverse(children)

    new_children =
      case hd(reversed_children) do
        {"p", _, content, _} ->
          [blockquote_footer(href, content) | tl(reversed_children)]

        _ ->
          [blockquote_footer(href, href) | reversed_children]
      end

    {"blockquote", attrs, Enum.reverse(new_children), annotations}
  end

  defp epigraph(attrs, children, annotations) do
    reversed_children = Enum.reverse(children)

    {"p", _, footer_content, _} = hd(reversed_children)
    footer = {"footer", [], footer_content, %{}}

    new_attrs = Enum.reject(attrs, &(elem(&1, 0) == "role"))
    new_children = Enum.reverse([footer | tl(reversed_children)])

    blockquote = {"blockquote", new_attrs, new_children, annotations}

    {"div", [{"class", "epigraph"}], [blockquote], %{}}
  end

  defp blockquote_footer(href, content) do
    anchor = {"a", [{"href", href}], List.wrap(content), %{}}

    {"footer", [], [anchor], %{}}
  end
end
