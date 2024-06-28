defmodule TuftemarkTest do
  # HINT: fswatch lib test | mix test --listen-on-stdin --only focus

  use ExUnit.Case, async: true

  defp compact_html(input),
    do: input |> String.replace(~r/>\s+</, "><") |> String.replace("\n", "")

  # @tag :focus
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

  # @tag :focus
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

  # @tag :focus
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

  describe "sidenotes" do
    # @tag :focus
    test "converts ordinary footnotes into marginal notes (without numbering)" do
      markdown = """
      Dictum vestibulum hac auctor[^hac-auctor] dictumst.

      [^hac-auctor]: Pulvinar dui pellentesque amet lacus.
      """

      expected = """
      <article>
        <section>
          <p>Dictum vestibulum hac auctor<label for="mn-hac-auctor" class="margin-toggle">⊕</label>
          <input type="checkbox" id="mn-hac-auctor" class="margin-toggle">
          <span class="marginnote">Pulvinar dui pellentesque amet lacus.</span> dictumst.</p>
        </section>
      </article>
      """

      assert compact_html(expected) == Tuftemark.as_html!(markdown, compact_output: true)
    end

    # @tag :focus
    test "converts special footnotes (dash-prefixed) into sidenotes (with numbering)" do
      markdown = """
      In print, Tufte has used the proprietary Monotype Bembo[^-bembo] font.

      [^-bembo]: See Tufte’s comment in the [Tufte book fonts](http://www.edwardtufte.com/bboard/q-and-a-fetch-msg?msg_id=0000Vt) thread.
      """

      expected = """
      <article>
        <section>
          <p>In print, Tufte has used the proprietary Monotype Bembo<label for="sn--bembo" class="margin-toggle sidenote-number"></label>
          <input type="checkbox" id="sn--bembo" class="margin-toggle">
          <span class="sidenote">See Tufte’s comment in the <a href="http://www.edwardtufte.com/bboard/q-and-a-fetch-msg?msg_id=0000Vt">Tufte book fonts</a> thread.</span> font.</p>
        </section>
      </article>
      """

      assert compact_html(expected) == Tuftemark.as_html!(markdown, compact_output: true)
    end
  end

  describe "figures" do
    # @tag :focus
    test "converts ordinary image-paragraphs into figures layout" do
      markdown = """
      Magnis montes dignissim.

      ![A lorem ipsum-like image](https://picsum.photos/200/300)

      From the Internet, _Picsum.photos_, size 200x300.
      {:role="caption"}
      """

      expected = """
      <article>
        <section>
          <p>Magnis montes dignissim.</p>
          <figure>
            <label for="mn-https-picsum-photos-200-300" class="margin-toggle">⊕</label>
            <input type="checkbox" id="mn-https-picsum-photos-200-300" class="margin-toggle">
            <span class="marginnote" role="caption">From the Internet, <em>Picsum.photos</em>, size 200x300.</span>
            <img src="https://picsum.photos/200/300" alt="A lorem ipsum-like image">
          </figure>
        </section>
      </article>
      """

      assert compact_html(expected) == Tuftemark.as_html!(markdown, compact_output: true)
    end
  end

  describe "blockquotes" do
    # @tag :focus
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

    # @tag :focus
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

    # @tag :focus
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
