defmodule TuftemarkTest do
  # HINT: fswatch lib test | mix test --listen-on-stdin --exclude skip

  use ExUnit.Case, async: true

  defp compact_html(input),
    do: input |> String.replace(~r/>\s+</, "><") |> String.replace("\n", "")

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

  # @tag :skip
  test "respects Kramdown syntax for sans class of a paragraph" do
    markdown = """
    If you prefer sans-serifs, use the `sans` class. It relies on Gill Sans, Tufte’s sans-serif font of choice.
    {:.sans}

    Usual serif text goes next.
    """

    expected = """
    <article>
      <section>
        <p class="sans">If you prefer sans-serifs, use the <code class="inline">sans</code> class. It relies on Gill Sans, Tufte’s sans-serif font of choice.</p>
        <p>Usual serif text goes next.</p>
      </section>
    </article>
    """

    assert compact_html(expected) == Tuftemark.as_html!(markdown, compact_output: true)
  end

  describe "footnotes" do
    # @tag :skip
    test "..." do
      markdown = """
      In print, Tufte has used the proprietary Monotype Bembo[^bembo] font.

      [^bembo]: See Tufte’s comment in the [Tufte book fonts](http://www.edwardtufte.com/bboard/q-and-a-fetch-msg?msg_id=0000Vt) thread.
      """

      expected = """
      <article>
        <section>
          <p>In print, Tufte has used the proprietary Monotype Bembo<label for="sn-bembo" class="margin-toggle sidenote-number"></label>
          <input type="checkbox" id="sn-bembo" class="margin-toggle">
          <span class="sidenote">See Tufte’s comment in the <a href="http://www.edwardtufte.com/bboard/q-and-a-fetch-msg?msg_id=0000Vt">Tufte book fonts</a> thread.</span> font.</p>
        </section>
      </article>
      """

      assert compact_html(expected) == Tuftemark.as_html!(markdown, compact_output: true)
    end
  end

  describe "blockquotes" do
    # @tag :skip
    test "converts last p tag to footer+a in a blockquote when a cite attribute set" do
      markdown = """
      > Lorem ipsum sit dolor amet.
      >
      > Id auctor turpis tortor.
      >
      > Famous Rome Citizens
      {:cite="https://example.com"}
      """

      expected = """
      <article>
        <section>
          <blockquote cite="https://example.com">
            <p>Lorem ipsum sit dolor amet.</p>
            <p>Id auctor turpis tortor.</p>
            <footer><a href="https://example.com">Famous Rome Citizens</a></footer>
          </blockquote>
        </section>
      </article>
      """

      assert compact_html(expected) == Tuftemark.as_html!(markdown, compact_output: true)
    end

    # @tag :skip
    test "adds a footer with link in a blockquote when a cite attribute set and last element is not p tag" do
      markdown = """
      > Per porttitor blandit.
      >
      > - some
      > - list
      > - here
      {:cite="https://example.com"}
      """

      expected = """
      <article>
        <section>
          <blockquote cite="https://example.com">
            <p>Per porttitor blandit.</p>
            <ul><li>some</li><li>list</li><li>here</li></ul>
            <footer><a href="https://example.com">https://example.com</a></footer>
          </blockquote>
        </section>
      </article>
      """

      assert compact_html(expected) == Tuftemark.as_html!(markdown, compact_output: true)
    end

    # @tag :skip
    test "leaves blockquote as it is when it's not citation" do
      markdown = """
      > Consequat sociosqu aptent nostra.
      >
      > Not So Famous Citizens of Rome
      """

      expected = """
      <article>
        <section>
          <blockquote>
            <p>Consequat sociosqu aptent nostra.</p>
            <p>Not So Famous Citizens of Rome</p>
          </blockquote>
        </section>
      </article>
      """

      assert compact_html(expected) == Tuftemark.as_html!(markdown, compact_output: true)
    end
  end
end
