defmodule TuftemarkTest do
  # HINT: fswatch lib test | mix test --listen-on-stdin --exclude skip

  use ExUnit.Case, async: true

  defp compact_html(input),
    do: input |> String.replace(~r/\n/, "") |> String.replace(~r/\>\s+/, ">")

  # @tag :skip
  test "wrap whole content in an article tag" do
    markdown = """
    # Lorem

    Ipsum!

    ## Sit dolor

    Amet.
    """

    expected = """
    <article>
      <h1>Lorem</h1>
      <p>Ipsum!</p>
      <h2>Sit dolor</h2>
      <p>Amet.</p>
    </article>
    """

    assert compact_html(expected) == Tuftemark.as_html!(markdown, compact_output: true)
  end
end
