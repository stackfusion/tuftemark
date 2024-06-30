defmodule Tuftemark.Figures do
  @moduledoc """
  Converts Markdown images to HTML figures with layout applicable to Tufte CSS.

  > [!info]
  >
  > If Markdown defines a `.fullwidth` image that is followed by a paragraph
  > supposed to the its `.caption`, we ignore the caption text (as we are not
  > sure how to render it properly yet). Maybe we will handle it later.

  > [!warning]
  >
  > At the original Tufte CSS [page](https://edwardtufte.github.io/tufte-css/),
  > we can see an example of a marginal image (the image of Rhinoceros). Authors
  > wrap a paragraph of text (that is visually right to the left of the marginal
  > image block) inside the marginnote itself.
  >
  > Our current implementation works a bit differently - it renders next
  > paragraph of Markdown text (that goes after the marginal image) as regular
  > `p` that goes after side note.
  >
  > Not a big deal, but it gives slightly other layout and on narrow screens
  > the margin toggle icon (by default it's `⊕`) rendered differently.
  """

  alias Earmark.{AstTools, Restructure}
  alias Tuftemark.Utils

  @init_acc %{image: nil, is_marginal: false, is_fullwidth: false}

  def process(ast) do
    ast
    |> Restructure.walk_and_modify_ast(@init_acc, &figure_out/2)
    |> elem(0)
  end

  # when it's a `p` with a single `img` child, we store it and wait for next el
  defp figure_out({"p", _, [{"img", _, _, _} = img], _} = item, acc) do
    is_marginal =
      item
      |> AstTools.find_att_in_node("class", "")
      |> String.contains?("marginal")

    is_fullwidth =
      item
      |> AstTools.find_att_in_node("class", "")
      |> String.contains?("fullwidth")

    {[], %{acc | image: img, is_marginal: is_marginal, is_fullwidth: is_fullwidth}}
  end

  # if it's a `p`, we check if it's a `.caption`, then render img respectively
  defp figure_out({"p", _, _, _} = item, acc) do
    is_caption =
      item
      |> AstTools.find_att_in_node("class", "")
      |> String.contains?("caption")

    cond do
      is_caption and acc.image ->
        {to_figure(acc, item), @init_acc}

      acc.image ->
        {to_figure(acc) ++ [item], @init_acc}

      true ->
        {item, acc}
    end
  end

  # in all other cases, we pass elements as is
  defp figure_out(item, acc), do: {item, acc}

  # the work horse of the whole image-figure postprocessor: does the heavy job
  # on actual rendering the final AST element to replace whatever in the source
  defp to_figure(image_opts, caption \\ nil) do
    %{image: image, is_marginal: is_marginal, is_fullwidth: is_fullwidth} = image_opts

    caption_unwrapped = if caption, do: elem(caption, 2), else: []

    # for/id attributes of sidenotes have to be uniq (on a document level), so
    # we rely on the `src` element...
    # ...yes, we would break convention, if render the same image twice on a page
    img_src = AstTools.find_att_in_node(image, "src", "")
    img_id = Regex.scan(~r/(\w+)/, img_src, capture: :all_but_first) |> Enum.join("-")

    # that's the trickiest part about images for Tufte CSS layouting because it
    # depends on a few factors on how exactly we want to render the image

    cond do
      # simply add a fullwidth class
      is_fullwidth ->
        [{"figure", [{"class", "fullwidth"}], [image], %{}}]

      # when it's a regular image, but it has caption: use sidenote for caption
      not is_marginal and caption ->
        sidenote = Utils.sidenote(img_id, [], caption_unwrapped, %{})

        [{"figure", [], sidenote ++ [image], %{}}]

      # when it's explicitly a marginal image: remix image and caption a bit
      is_marginal and caption ->
        sidenote = Utils.sidenote(img_id, [], [image | caption_unwrapped], %{})

        [{"p", [], sidenote, %{}}]

      # when no caption provided to a marginal image: put it all to the side
      is_marginal ->
        sidenote = Utils.sidenote(img_id, [], [image], %{})

        [{"p", [], sidenote, %{}}]

      # otherwise, go with a simple `figure` tag wrapper
      true ->
        [{"figure", [], [image], %{}}]
    end
  end
end
