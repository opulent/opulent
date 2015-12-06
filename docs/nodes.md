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

a href="google" > i.fa.fa-circle
  | Hello world
```

```html
<ul>
  <li>
    <a href="http://google.com">Google</a>
  </li>
</ul>

<a href="http://google.com">
  <i class="fa fa-circle"></i>
  Google
</a>
```

## Inline Text Feed
We can write text directly inline with our node.

```sass
p This is <escaped> inline text
p ~ This is <unescaped> inline text

p | This is <escaped> multiline text
  which is more indented than the paragraph node.
p |~ This is <unescaped> multiline text
  which is more indented than the paragraph node.
```

```html
<p>This is &lt;escaped&gt; inline text</p>
<p>This is <unescaped> inline text</p>

<p>This is &lt;escaped&gt; multiline text which is more indented than the paragraph node.</p>
<p>This is <escaped> multiline text which is more indented than the paragraph node.</p>
```

## Explicit Inline Text Feed
If we want Opulent to parse the following part as text explicitly, we can use a backslash `\` character,
which stops the parsing of the current line and starts getting a text feed.

```
p id="paragraph" Inside

p \id="paragraph" Inside
```

The `\` character will gather the rest of the line as text.

```html
<p id="paragraph">Inside</p>

<p>id="paragraph" Inside</p>
```

## Whitespace

Sometimes we need to leave a leading or trailing whitespace at a certain node, like `strong` or `a`.
We can do that using pointer arrows.

```
| We want a space before
strong<- this text.
```

```
strong-> This text
| has a space after it.
```

```
| Before
strong<-> this text
| and after it.
```

## Self Enclosing

We can explicitly self enclose nodes. By default, Opulent knows that nodes such as `img` need to be self enclosed.

```
mynode /
```

```html
<mynode>
```
