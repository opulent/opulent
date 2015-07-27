#Opulent Syntax

## Attributes
Tag attributes are similar to CSS or HTML, but their values are regular embedded Ruby.

### Shorthand Attributes
You can use the shorthand attributes exactly as you would in your CSS markup, the syntax is very similar.

The default node for the shorthand attributes is the __div__ node, since it's the most widely used HTML Element.

__Opulent__
```html
.block.block-center

#content

#content.block
```

__HTML__
```html
<div class="block block-center"></div>

<div id="content"></div>

<div id="content" class="block"></div>
```


### Wrapped Attributes
You can either use equals symbol '__=__' or colon symbol '__:__' to set a value for an attribute.

The difference between wrapped and unwrapped (inline) attributes is that you can use complex Ruby expressions such as boolean operations, comparisons or ternary operators.

Attributes can be wrapped in round __(exp)__, square __[exp]__ and curly __{exp}__ brackets.

__Opulent__
```html
a(href="http://google.com") Google
a(href: "http://google.com") Google

a[href="http://google.com"] Google
a[href: "http://google.com"] Google

a{href="http://google.com"} Google
a{href: "http://google.com"} Google
```



### Inline Attributes
Inline attributes can be used without any wrapping brackets and they allow you to use simple expressions.

__Opulent__
```html
a href="http://google.com" Google

a href="http://google.com" class="button" Google
```

__HTML__
```
<a href="http://google.com">Google</a>

<a href="http://google.com" class="button">Google</a>
```
