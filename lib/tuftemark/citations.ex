defmodule Tuftemark.Citations do
  alias Earmark.{Restructure}

  def process(ast) do
    ast
    |> Restructure.walk_and_modify_ast([], &find_and_replace/2)
    |> elem(0)
  end

  defp find_and_replace({"blockquote", attrs, children, _} = item, acc) do
    case Enum.find(attrs, &(elem(&1, 0) == "cite")) do
      nil ->
        {item, acc}

      {"cite", href} ->
        reversed_children = Enum.reverse(children)

        new_children =
          case hd(reversed_children) do
            {"p", _, content, _} ->
              [blockquote_footer(href, content) | tl(reversed_children)]

            _ ->
              [blockquote_footer(href, href) | reversed_children]
          end

        {{"blockquote", attrs, Enum.reverse(new_children), %{}}, acc}
    end
  end

  defp find_and_replace(item, acc), do: {item, acc}

  defp blockquote_footer(href, content) do
    anchor = {"a", [{"href", href}], List.wrap(content), %{}}

    {"footer", [], [anchor], %{}}
  end
end
