# Opulent

Opulent is an __Intelligent Web Templating Engine__ created for extremly fast, efficient and DRY Web Development. Based on the idea of creating lightweight __Web Component__ definitions, Opulent greatly speeds up the development process of any project.

## Syntax

Opulent is as beautiful as it gets: no tags, indentation based, optional brackets, inline text, inline children and in page definitions.

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

__Web Component__
```
def hello(place)
  p Hello #{place}

hello place="World"
```

__Control Structures__
```
ul.navbar
  if @user.logged_in?
    li Hello #{@user.name}
  else
    li > a href=link_to_register Sign Up
```

__Starting to feel it?__ There's so much more you can do with Opulent.

[Read the Documentation](docs/syntax.md)



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

[Read the Documentation](docs/usage.md)

```ruby
require 'opulent'

Opulent.new.render_file 'file.op'
```

<!--
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).
-->

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/opulent/opulent. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

#### Under Development
Opulent is currently in the Beta Phase. It has serious potential to becoming the next generation of Templating Engines for Ruby, therefore any contribution is more than welcome.

It still has development going on the following subjects:

* Template amble (preamble, cache, postamble) generation
* More block yielding tests
* Multiple page layouts
* More to come

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
