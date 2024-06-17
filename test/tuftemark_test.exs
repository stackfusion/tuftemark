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
      <section>
        <h1>Lorem</h1>
        <p>Ipsum!</p>
      </section>
      <section>
        <h2>Sit dolor</h2>
        <p>Amet.</p>
      </section>
    </article>
    """

    assert compact_html(expected) == Tuftemark.as_html!(markdown, compact_output: true)
  end

  # @tag :skip
  test "split content into sections around every h2 tag" do
    markdown = """
    # Class vehicula

    Torquent convallis inceptos.

    ## Erat ipsum eros

    ### Nullam velit

    Dapibus mollis pharetra morbi.

    ## Habitasseduis

    Duis orci.
    """

    expected = """
    <article>
      <section>
        <h1>Class vehicula</h1>
        <p>Torquent convallis inceptos.</p>
      </section>
      <section>
        <h2>Erat ipsum eros</h2>
        <h3>Nullam velit</h3>
        <p>Dapibus mollis pharetra morbi.</p>
      </section>
      <section>
        <h2>Habitasseduis</h2>
        <p>Duis orci.</p>
      </section>
    </article>
    """

    assert compact_html(expected) == Tuftemark.as_html!(markdown, compact_output: true)
  end
end
