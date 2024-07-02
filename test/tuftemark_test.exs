defmodule TuftemarkTest do
  # HINT: fswatch lib test | mix test --listen-on-stdin --only focus

  use ExUnit.Case, async: true

  defp compact_html(input),
    do: input |> String.replace(~r/>\s+</, "><") |> String.replace("\n", "")

  ##############################################################################
  # BASICS, GENERAL                                                            #
  ##############################################################################

  describe "basics, general" do
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
  end

  ##############################################################################
  # BLOCKQUOTES                                                                #
  ##############################################################################

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
    test "converts a blockquote into epigraph when it has such a class" do
      markdown = """
      > For a successful technology, reality must take precedence over public relations, for Nature cannot be fooled.
      >
      > Richard P. Feynman, _“What Do You Care What Other People Think?”_
      {:.epigraph}
      """

      expected = """
      <article>
        <section>
          <div class="epigraph">
            <blockquote>
              <p>For a successful technology, reality must take precedence over public relations, for Nature cannot be fooled.</p>
              <footer>Richard P. Feynman, <em>“What Do You Care What Other People Think?”</em></footer>
            </blockquote>
          </div>
        </section>
      </article>
      """

      assert compact_html(expected) == Tuftemark.as_html!(markdown, compact_output: true)
    end

    # @tag :focus
    test "leaves blockquote as it is when it's nothing specific" do
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

  ##############################################################################
  # FIGURES                                                                    #
  ##############################################################################

  describe "figures" do
    @tag :focus
    test "converts regular images by replacing parent `p` tag with the `figure` one" do
      markdown = """
      Fusce sed Lorem.

      ![Alt text goes here](/path/to/image.jpg)

      Id scelerisque vehicula.
      """

      expected = """
      <article>
        <section>
          <p>Fusce sed Lorem.</p>
          <figure>
            <img src="/path/to/image.jpg" alt="Alt text goes here">
          </figure>
          <p>Id scelerisque vehicula.</p>
        </section>
      </article>
      """

      assert compact_html(expected) == Tuftemark.as_html!(markdown, compact_output: true)
    end

    @tag :focus
    test "converts fullwidth images when .fullwidth class set to the image" do
      markdown = """
      Nisi laoreet ornare.

      ![Alternative text](/another/i-m-a-g-e.png)
      {:.fullwidth}

      Congue est fringilla dui luctus.
      """

      expected = """
      <article>
        <section>
          <p>Nisi laoreet ornare.</p>
          <figure class="fullwidth">
            <img src="/another/i-m-a-g-e.png" alt="Alternative text">
          </figure>
          <p>Congue est fringilla dui luctus.</p>
        </section>
      </article>
      """

      assert compact_html(expected) == Tuftemark.as_html!(markdown, compact_output: true)
    end

    # TODO: try to handle captions somehow, maybe to render them in a special way after the image...
    @tag :focus
    test "converts fullwidth images and ignores caption (as we don't have a place where to put it)" do
      markdown = """
      Elit eget elit habitant.

      ![Example image](https://example.com/hello.gif)
      {:.fullwidth}

      Mus vehicula metus turpis.
      {:.caption}

      Dictumst class purus proin nisl.
      """

      expected = """
      <article>
        <section>
          <p>Elit eget elit habitant.</p>
          <figure class="fullwidth">
            <img src="https://example.com/hello.gif" alt="Example image">
          </figure>
          <p>Dictumst class purus proin nisl.</p>
        </section>
      </article>
      """

      assert compact_html(expected) == Tuftemark.as_html!(markdown, compact_output: true)
    end

    @tag :focus
    test "converts regular images with captions into a figure with marginnote layout" do
      markdown = """
      Magnis montes dignissim.

      ![A lorem ipsum-like image](https://picsum.photos/200/300)

      From the Internet, _Picsum.photos_, size 200x300.
      {:.caption}

      Duis mattis inceptos interdum.
      """

      expected = """
      <article>
        <section>
          <p>Magnis montes dignissim.</p>
          <figure>
            <label for="mn-https-picsum-photos-200-300" class="margin-toggle">⊕</label>
            <input type="checkbox" id="mn-https-picsum-photos-200-300" class="margin-toggle">
            <span class="marginnote">From the Internet, <em>Picsum.photos</em>, size 200x300.</span>
            <img src="https://picsum.photos/200/300" alt="A lorem ipsum-like image">
          </figure>
          <p>Duis mattis inceptos interdum.</p>
        </section>
      </article>
      """

      assert compact_html(expected) == Tuftemark.as_html!(markdown, compact_output: true)
    end

    @tag :focus
    test "converts marginal images with a caption and captures the next usual paragraph of text" do
      markdown = """
      Ante lacus sociosqu litora.

      ![Square image](https://picsum.photos/100/100)
      {:.marginal}

      The Squared One, _Picsum.photos_, size 100x100.
      {:.caption}

      Torquent montes tincidunt.

      Pellentesque himenaeos aliquet.
      """

      expected = """
      <article>
        <section>
          <p>Ante lacus sociosqu litora.</p>
          <p>
            <label for="mn-https-picsum-photos-100-100" class="margin-toggle">⊕</label>
            <input type="checkbox" id="mn-https-picsum-photos-100-100" class="margin-toggle">
            <span class="marginnote">
              <img src="https://picsum.photos/100/100" alt="Square image">The Squared One, <em>Picsum.photos</em>, size 100x100.</span>
          </p>
          <p>Torquent montes tincidunt.</p>
          <p>Pellentesque himenaeos aliquet.</p>
        </section>
      </article>
      """

      assert compact_html(expected) == Tuftemark.as_html!(markdown, compact_output: true)
    end

    @tag :focus
    test "converts marginal images without a caption" do
      markdown = """
      Vel sapien ligula senectus.

      ![A tall picture](https://picsum.photos/300/100)
      {:.marginal}

      Aliquam elit ultricies etiam congue.
      """

      expected = """
      <article>
        <section>
          <p>Vel sapien ligula senectus.</p>
          <p>
            <label for="mn-https-picsum-photos-300-100" class="margin-toggle">⊕</label>
            <input type="checkbox" id="mn-https-picsum-photos-300-100" class="margin-toggle">
            <span class="marginnote">
              <img src="https://picsum.photos/300/100" alt="A tall picture">
            </span>
          </p>
          <p>Aliquam elit ultricies etiam congue.</p>
        </section>
      </article>
      """

      assert compact_html(expected) == Tuftemark.as_html!(markdown, compact_output: true)
    end
  end

  ##############################################################################
  # SIDENOTES                                                                  #
  ##############################################################################

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
end
