defmodule Tuftemark.Figures do
  alias Earmark.Restructure
  alias Tuftemark.Utils

  def process(ast) do
    ast
    |> Restructure.walk_and_modify_ast(nil, &find_and_replace/2)
    |> elem(0)
  end

  defp find_and_replace({"p", attrs, children, _} = item, acc) do
    starter = hd(children)

    is_image = is_tuple(starter) and elem(starter, 0) == "img"
    is_caption = Enum.any?(attrs, &(&1 == {"role", "caption"}))

    cond do
      is_image -> {[], item}
      is_caption -> {to_figure(item, acc), acc}
      true -> {item, acc}
    end
  end

  defp find_and_replace(item, acc), do: {item, acc}

  defp to_figure({"p", attrs, children, annotations}, {_, _, [image_tag], _}) do
    img_src = image_tag |> elem(1) |> Enum.find(&(elem(&1, 0) == "src")) |> elem(1)
    img_id = Regex.scan(~r/(\w+)/, img_src, capture: :all_but_first) |> Enum.join("-")

    sidenote = Utils.sidenote(img_id, attrs, children, annotations)

    [{"figure", [], sidenote ++ [image_tag], %{}}]
  end
end