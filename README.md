# Opulent
[![Build Status](https://travis-ci.org/opulent/opulent.svg?branch=master)](https://travis-ci.org/opulent/opulent)

Opulent [(opulent.io)](http://opulent.io) is a templating engine which strives to make page markup as beautiful and expressive as it should be. It's blazing fast, offers useful reusable component definitions and encourages well organised front end code. Opulent provides the cleanliness, readability and development speed you need for your project.

[Visit Homepage](http://opulent.io/)

## Syntax
Opulent has a beautiful, minimalistic syntax: no tags, indentation based, optional brackets, inline text, inline children and in page definitions.

__Page Markup__
```
html
  head
    title Opulent is Awesome
  body
    #content
      ul.list-inline
        li > a href="http://opulent.io" Opulent
        li > a href="http://github.com" GitHub

    footer |
      With Opulent, you can do anything.
```

__Reusable Component__
```
def hello(place)
  p Hello #{place}
  
hello place="World"
```

```
def content
  #content
    yield
  
content 
  h1 I'll replace yield!
```


__Control Structures__
```
ul.navbar
  if @user.logged_in?
    li Hello #{@user.name}
  else
    li > a href=link_to_register Sign Up
```

### Elegant
Markup should beautiful and clean. Opulent makes markup a pleasant experience.

### Reusable
Completely DRY, in opulent you can define reusable markup elements easily.

### Full Featured
Everything you need, right from the start. Ready for all the major Ruby frameworks.

### Performant
Opulent is lightweight, blazing fast. Performance is measured with every release.

__Like it?__ There's so much more you can do with Opulent.

[Read the Documentation](http://opulent.io/documentation/)



## Installation

Install it yourself using the ruby gem:

    $ gem install opulent

---

Or add this line to your application's Gemfile:

```ruby
gem 'opulent'
```

And then execute:

    $ bundle


## Usage

Using Opulent to render a file is as easy as including it in your application and using the render method.

[Read the Documentation](http://opulent.io/documentation/)

```ruby
require 'opulent'

engine = Opulent.new(:index)
output = engine.render
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/opulent/opulent. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

#### Production Ready
Opulent is production ready and has serious potential to becoming the next generation of Templating Engines for Ruby, therefore any contribution is more than welcome.



## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
