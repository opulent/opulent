# Opulent Attributes
Tag attributes are similar to CSS or HTML, but their values are regular embedded Ruby.

### Shorthand Attributes
You can use the shorthand attributes exactly as you would in your CSS markup, the syntax is very similar.

The default node for the shorthand attributes is the __div__ node, since it's the most widely used HTML Element.

__Example__
```scss
.container.text-center

#content

#main.center

div#block.new

input&email
```

```html
<div class="container text-center"></div>

<div id="content"></div>

<div id="main" class="center"></div>

<div id="block" class="new"></div>

<input name="email">
```


### Wrapped Attributes
You can either use equals symbol '__=__' or colon symbol '__:__' to set a value for an attribute.

The difference between wrapped and unwrapped (inline) attributes is that you can use complex Ruby expressions such as boolean operations, comparisons or ternary operators.

The attributes in wrapped mode are separated by a comma '__,__' or semicolon '__;__'.

The node's __class__ attribute values are gathered into an array, while the other attributes will be replaced.

Attributes can be wrapped in round __(exp)__, square __[exp]__ and curly __{exp}__ brackets.

__Example 1__
```html
a(href="http://google.com") Google
a(href: "http://google.com") Google

a[href="http://google.com"] Google
a[href: "http://google.com"] Google

a{href="http://google.com"} Google
a{href: "http://google.com"} Google
```

```html
<a href="http://google.com">Google</a>
```

__Example 2__

```html
div(class: "HELLO".downcase, class: "world")
```

```html
<div class="hello world"></div>
```

__Example 3__
```html
a(class=["btn", "btn-primary"])
```

```html
<a class="btn btn-primary"></a>
```

__Example 4__
```html
example(attr1=1 + 2 + 3, attr2="hello " + "world")
```

```html
<example attr1="6" attr2="hello world"></example>
```

### Unwrapped Attributes
Inline attributes can be used without any wrapping brackets and they allow you to use simple expressions such as method calls and index accessors.

__Example 1__
```html
a href="http://google.com" Google

a href="http://google.com" class="button" Google
```

```
<a href="http://google.com">Google</a>

<a href="http://google.com" class="button">Google</a>
```

__Example 2__
```html
a class=["btn", "btn-primary"] Button
```

```html
<a class="btn btn-primary">Button</a>
```

### Escaping Attributes
Attributes are escaped by default, unless passed as node definition arguments.

You can use a tilde symbol '__~__' after the assignment operator to explicitly set the attribute value as unescaped.

__Example__
```html
div escaped="<div></div>"
div unescaped=~"<div></div>"
```

```html
<div escaped="&lt;div&gt;&lt;/div&gt;"></div>
<div unescaped="<div></div>"></div>
```

Unescaped buffered code can be dangerous. You must be sure to sanitize any user inputs to avoid cross-site scripting.

### Extending Attributes
Attributes can be extended using a '__+__' symbol, followed by an expression which provides Hash.

__Example__
```html
a+({href: "http://opulent.io", class: "btn btn-black"}) Opulent
```
```html
<a href="http://opulent.io" class="btn btn-black">Opulent</a>
```


### Literal Values
In Opulent, boolean values, arrays and hashes behave differently based on the use context. Arrays will join values using a space when used for class attributes and an underline otherwise. Hashes will extend the current attribute name one level using the hash key.

__Example 1__
```html
- hash = {a: 1, b: 2, c: 3}
div data=hash
```

```html
<div data-a="1" data-b="2" data-c="3"></div>
```

```html
- array = ['a', 'b', 'c']
div data=array class=array
```
```html
<div data="a_b_c" class="a b c"></div>
```
