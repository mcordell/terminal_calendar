# TTY::Calendar

> A calendar and day picker for the terminal

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add tty-calendar

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install tty-calendar

## Usage

`tty-calendar` can be used to render a calendar page similar to the linux tool `cal`:

```
require 'tty-calendar'
# this will render a calendar for the current month to the command line
puts TTY::Calendar.cal
```

![cal screenshot](./_doc/cal-screenshot.png) 

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mcordell/tty-calendar.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/license/mit/).

## Copyright

Copyright (c) 2023 Michael Cordell. See LICENSE for further details.
