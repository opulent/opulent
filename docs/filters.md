# Opulent Filters

Filters let you use other languages within a opulent template. They take a block of plain text as an input.
Some filters also have a default tag associated with them, such as the `css` filter and `javascript` filter.

```html
:markdown
  # Markdown

  I often like including markdown documents.

:coffee-script
  console.log 'This is coffeescript'
```

By default, the following filters are included:

```
:coffeescript
:javascript
:scss
:sass
:css
:cdata
:escaped
:markdown
:maruku
:textile
```

Each filter uses its associated gem and requires it to be installed.
