# Tuftemark

[Online Documentation](https://hexdocs.pm/tuftemark).

<!-- MDOC !-->

Tuftemark converts Markdown content into format that is suitable to be used with
[Tufte CSS](https://github.com/edwardtufte/tufte-css) tool.

Tufte CSS layout requires a few things to be applied to the HTML, for example:

- the whole post must be wrapped in `<article>` tag
- content must be split into `<section>`s around every H2 tag
- footnotes must be converted into margin notes (compatible with the CSS)

The `as_html!/2` method is trying to apply all the given transformation to the
originally parsed AST, so we get applicable HTML output in the end.

## Extra Modifications

Some of layout decisions cannot be made automatically, but we can use some super
powers provided us by default Earmark's Parser.

For example:

- if we want a paragraph written in sans-serif, we can use Kramdown syntax for
  attributes: (`{:.sans}`);
- if we want to provide a citation (as a blockquote), we can use set an attr:
  `{:cite="https://example.com"}`;

See all such examples in the TuftemarkTest suite.

## Installation

The package can be installed by adding `tuftemark` to your list of dependencies
in `mix.exs`:

```elixir
def deps do
  [
    {:tuftemark, "~> 0.1.0"}
  ]
end
```
