# Opulent Control Structures

You can use your favorite control structures from Ruby in Opulent without any hassle. Unlike in most templating engines, control structures do not require a leading dash and can be written like you normally write a node.

### If Structure
Just like in Ruby, you can use the __if-elsif-else__ structure to write conditional branches. The values false and nil are false, and everything else are true. Notice Ruby and Opulent use elsif, not else if nor elif.

__Example__
```html
if user.authenticated?
  p Welcome #{user.name}
else
  p Welcome stranger!
```

### Unless Structure
The branch is executed if the condition is false. The unless structure also allows an else branch.

__Example__
```html
unless value
  p Value doesn't exist
```

### Case Structure
To handle multiple possible values, the case structure is preferred instead of the if-elsif structure.

__Example__
```html
- value = 'a'

case value
when 'a'
  p This is a
when 'b'
  p This is b
when 'c'
  p This is c
else
  p This is something else
```

### Each Structure
The each structure will iterate through an ennumerable value such as an Array or Hash and allow you to use
the value and the current index. By default, the variable names are '__key__' and '__value__' but they can be overwritten.

__Example 1__
```html
each in ['a', 'b', 'c']
  p Value at #{key} is #{value}.
```

```html
<p>Value at 0 is a.</p>
<p>Value at 1 is b.</p>
<p>Value at 2 is c.</p>
```

__Example 2__
```html
each myval in ['1', '2', '3']
  p Value at #{key} is #{myval}.
```

__Example 3__
```html
each k, v in {a: '1', b: '2', c: '3'}
  p Value at #{k} is #{v}.
```

### While Structure
The while structure will loop until we encounter a false value for the conditional. You will need to update the  conditional variables inside the while loop in order to eventually reach a false value, otherwise it will result in an infinite loop.

__Example__
```html
- timer = 10
while timer > 0
  p Time remaining: #{timer}
  - timer -= 1
```

### Until Structure
The until structure will loop until we encounter a true value for the conditional.

__Example__
```html
- timer = 10
until timer == 0
  p Time left: #{timer}
  - timer -= 1
```
