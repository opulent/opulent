# Opulent Usage

Opulent can be used to render a file by providing a symbol with the name of the file or to render code by providing a string input.

```ruby
require 'opulent'

Opulent.new.render_file :index
```

Opulent comes with a built in layout system. So if you're not using any web development framework, you'll really appreciate that.
For layouts you can simply use the following code. By default, the layout is set to __layouts/application__.

```ruby
require 'opulent'

opulent = Opulent.new layouts: true
opulent.render_file :index, layout: :'path/to/layout'
```

Here is a list of options you can use with opulent at the moment together with their default values.

```ruby
options = {
  indent: 2,
  layouts: false,
  default_layout: :'views/layouts/application'
}
opulent = Opulent.new options
```
