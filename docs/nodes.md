# Opulent Nodes

Opulent has several node features which can be used within your views.

## Syntax
By default, every identifier can be a node, except the few keywords that Opulent uses for itself (e.g. def, yield, if, else, etc.).
```sass
node-name
```
Will render as:
```html
<node-name></node-name>
```

The following will render the same output:
```sass
div class="myclass"
div.myclass
.myclass
.("myclass")
."myclass"
```
```html
<div class="myclass"></div>
```

## Inline Child Nodes
Nodes such as text can be written inline without any identifier. However, when we want to have child nodes written inline we use the `>` character.

```sass
ul
  li > a href="http://google.com" Google
```
