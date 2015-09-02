# Opulent Expressions

Opulent makes it possible to write inline Ruby code in your templates. There are a few types of code.

##Unbuffered Code
Unbuffered code starts with `-` (single line) or `+` (multi line) and does not provide an output directly.

```sass
- a = 1 + 2 + 3

+ if a == 6
    a = 3
  end
```

## Buffered Code
Buffered code starts with `=` and it outputs the Ruby expression as plain text. For safety reasons, it will be escaped by default.

```sass
p = "this is " + "an <escaped> ruby expression"
```

```html
<p>
  this is an &lt;escaped&gt; ruby expression
</p>
```

## Unuffered Code
Whenever we want to unescape an output in Opulent, we use the tilde character `~` to do so.

```sass
p =~ "this is " + "an <escaped> ruby expression"
```

```html
<p>this is an <escaped> ruby expression</p>
```
