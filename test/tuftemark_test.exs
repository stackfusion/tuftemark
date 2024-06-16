defmodule TuftemarkTest do
  use ExUnit.Case, async: true

  test "wrap whole content in an article tag" do
    markdown = """
    # Lorem

    Ipsum!

    ## Sit dolor

    Amet.
    """

    html = "<article><h1>Lorem</h1><p>Ipsum!</p><h2>Sit dolor</h2><p>Amet.</p></article>"

    assert html == Tuftemark.as_html!(markdown, compact_output: true)
  end
end
