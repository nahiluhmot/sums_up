# sums_up

Sum types for Ruby with zero runtime dependencies. Inspired by [hojberg/sums-up](https://github.com/hojberg/sums-up).

[![Build Status](https://travis-ci.org/nahiluhmot/sums_up.svg?branch=master)](https://travis-ci.org/nahiluhmot/sums_up)
[![Gem Version](https://badge.fury.io/rb/sums_up.svg)](https://badge.fury.io/rb/sums_up)

* [What is a Sum Type?](#what-is-a-sum-type)
* [Quick Start](#quick-start)
* [Defining Sum Types](#defining-sum-types)
* [Predicates](#predicates)
* [Pattern Matching with Hashes](#pattern-matching-with-hashes)
* [Pattern Matching with Blocks](#pattern-matching-with-blocks)
* [Methods on Sum Types](#methods-on-sum-types)
* [Variant Instance Methods](#variant-instance-methods)
* [A Note on Mutability](#a-note-on-mutability)
* [Maybes](#maybes)
* [Results](#results)
* [Why?](#why)
* [Development](#development)
* [Contributing](#contributing)
* [License](#license)
* [Code of Conduct](#code-of-conduct)

## What is a Sum Type?

Sum types are data structures with multiple variants.
Ruby does not have sum types, but many concepts in the language (like booleans, integers, errors, state machines, etc.) can be described using sum types.
Sum types are not limited to those use-cases, however, and are a powerful tool for modeling domain-specific data as well.

This README uses non-generalized examples of sum types to help build an intuition for when they might be useful.
To learn more about sum types, I recommend watching [Philip Wadler's Category Theory for the Working Hacker](https://www.youtube.com/watch?v=V10hzjgoklA) and checking out [Elm's Custom Types](https://guide.elm-lang.org/types/custom_types.html), [Haskell's Sum Types](https://www.schoolofhaskell.com/school/to-infinity-and-beyond/pick-of-the-week/sum-types), [Rust's Enums](https://doc.rust-lang.org/book/ch06-01-defining-an-enum.html), and the [Wikipedia article on Algebraic data types](https://en.wikipedia.org/wiki/Algebraic_data_type).

## Quick Start

Define a sum type:

```ruby
Direction = SumsUp.define(:north, :south, :east, :west)
# => Direction

Direction.north
# => #<variant Direction::North>

Direction.south
# => #<variant Direction::South>

Direction.east
# => #<variant Direction::East>

Direction.west
# => #<variant Direction::West>
```

Use predicates to distinguish between variants:

```ruby
def latitudinal?(direction)
  direction.north? ||
    direction.south?
end

latitudinal?(Direction.south)
# => true

latitudinal?(Direction.west)
# => false
```

Call `#match` to categorically handle each variant by name:

```ruby
def turn_clockwise(direction)
  direction.match do |m|
    m.north { Direction.east }
    m.south { Direction.west }
    m.east { Direction.south }
    m.west { Direction.north }
  end
end

turn_clockwise(Direction.north)
# => #<variant Direction::East>

turn_clockwise(turn_clockwise(Direction.north))
# => #<variant Direction::South>
```

## Defining Sum Types

Imagine we're writing software for a coffee shop.
The menu might look something like this:

| Item                 | Small | Large |
|----------------------|-------|-------|
| Water                | Free  |       |
| Lemonade             | $3.50 | $4.50 |
| Coffee (Hot or Iced) | $2.95 | $3.95 |

To model the menu using sum types, let's start out with some simple enumerations:

```ruby
Size = SumsUp.define(:small, :large)
# => Size

Temperature = SumsUp.define(:hot, :iced)
# => Temperature

Size.small
# => #<variant Size::Small>

Size.large
# => #<variant Size::Large>

Temperature.hot
# => #<variant Temperature::Hot>

Temperature.iced
# => #<variant Temperature::Iced>
```

Enumerations work well for `Size` and `Temperature`, but defining a `Drink` type will be a bit more work.
There are multiple kinds of drinks (water, lemonade, and coffee), each of which has a varying set of attributes (some drinks are available in multiple sizes, coffee can be served hot or iced).

To describe these relationships, let's define a sum type with variants who have members.
In the below example, `Drink.water` has no members, `Drink.lemonade` has a `size`, and `Drink.coffee` has a `size` and `temperature`:

```ruby
Drink = SumsUp.define(
  :water,
  lemonade: :size,
  coffee: [:size, :temperature]
)
# => Drink

Drink.water
# => #<variant Drink::Water>

lemonade = Drink.lemonade(Size.small)
# => #<variant Drink::Lemonade size=#<variant Size::Small>>

lemonade.size
# => #<variant Size::Small>

coffee = Drink.coffee(Size.large, Temperature.iced)
# => #<variant Drink::Coffe size=#<variant Size::Large> temperature=#<variant Temperature::Iced>>

coffee.size
# => #<variant Size::Large>

coffee.temperature
# => #<variant Temperature::Iced>

# Raises because only coffee and lemonade have a size.
Drink.water.size
# => NoMethodError: undefined method `size' for #<variant Drink::Water>
```

## Predicates

Predicates are defined for each variant of a sum type:

```ruby
Size.large.large?
# => true

Temperature.hot.iced?
# => false

Temperature.iced.iced?
# => true

Drink.water.coffee?
# => false

# Raises because Temperature only has `#hot?` and `#iced?` predicates.
Temperature.hot.water?
# => NoMethodError: undefined method `water?' for #<variant Temperature::Hot>
```

We can use these to write a function which returns the `Temperature` for a given `Drink`.
`Drink.coffee` is the only variant which has an explicit `temperature` attribute, but we know that both `Drink.water` and `Drink.lemonade` are only served iced.

```ruby
def drink_temperature(drink)
  if drink.coffee?
    drink.temperature
  else
    Temperature.iced
  end
end

drink_temperature(Drink.lemonade(Size.large))
# => #<variant Temperature::Iced>

drink_temperature(Drink.coffee(Size.small, Temperature.hot))
# => #<variant Temperature::Hot>
```

## Pattern Matching with Hashes

Another way to distinguish sum type variants is pattern matching.
We can use pattern matching with Hashes to define formatters for `Size` and `Temperature`:

```ruby
def format_size(size)
  size.match(small: 'Small', large: 'Large')
end

def format_temperature(temperature)
  temperature.match(hot: 'Hot', iced: 'Iced')
end

format_size(Size.large)
# => 'Large'

format_temperature(Temperature.iced)
# => 'Iced'
```

In some cases, it can be convenient to match against some variants and use a wildcard for the rest:

```ruby
def free?(drink)
  drink.match(water: true, _: false)
end

free?(Drink.water)
# => true

free?(Drink.lemonade(Size.large))
# => false
```

`#match` will raise if any variants are left unmatched.
The following method does not handle `Drink.water` and will raise whenever any drink is provided:

```ruby
def added_sugar?(drink)
  drink.match(lemonade: true, coffee: false)
end

# Raises because water is not matched.
added_sugar?(Drink.water)
# => SumsUp::UnmatchedVariantError: Did not match the following variants: water

# Raises because water is not matched, even though a lemonade is getting passed in.
added_sugar?(Drink.lemonade(Size.large))
# => SumsUp::UnmatchedVariantError: Did not match the following variants: water
```

## Pattern Matching with Blocks

Matching against the variant name is often not enough, we need to be able to use the variant's members as well.
For these use-cases, `#match` accepts a block.
For variants with members, each member is yielded to the `#match` block:

```ruby
def format_drink(drink)
  drink.match do |m|
    m.water { 'Water' }
    m.lemonade { |size| "#{format_size(size)} Lemonade" }
    m.coffee do |size, temperature|
      "#{format_size(size)} #{format_temperature(temperature)} Coffee"
    end
  end
end

format_drink(Drink.water)
# => 'Water'

format_drink(Drink.lemonade(Size.small))
# => 'Small Lemonade'

format_drink(Drink.coffee(Size.large, Temperature.iced))
# => 'Large Iced Coffee'
```

Like Hash-based pattern matching, Block-based pattern matching can use wildcards as well.
The below example redefines `drink_temperature` using pattern matching:

```ruby
def drink_temperature(drink)
  drink.match do |m|
    m.coffee { |_size, temperature| temperature }
    m._ { Temperature.iced }
  end
end

drink_temperature(Drink.water)
# => #<variant Temperature::Iced>
```

Note: if using the wildcard pattern matcher (`_`), it must come after the explicit variant matches.

The match syntax also supports passing values directly to the matcher, as opposed to passing a block:

```ruby
# Waters are always small, other drinks use their specified size.
def drink_size(drink)
  drink.match do |m|
    m.water Size.small
    m.lemonade { |size| size }
    m.coffee { |size, _temperature| size }
  end
end

drink_size(Drink.water)
# => #<variant Size::Small>

drink_size(Drink.lemonade(Size.small))
# => #<variant Size::Small>
```

This syntax will also raise if not all variants of a type are matched:

```ruby
def drink_price(drink)
  drink.match do |m|
    m.water 0
    m.lemonade { |size| size.match(small: 350, large: 450) }
  end
end

# Raises because coffee is not matched.
drink_price(Drink.coffee(Size.large, Temperature.hot))
# => SumsUp::UnmatchedVariantError: Did not match the following variants: coffee

# Raises because coffee is not matched, even though a water is getting passed in.
drink_price(Drink.water)
# => SumsUp::UnmatchedVariantError: Did not match the following variants: coffee
```

## Methods on Sum Types

When defining a sum type, we can add methods to it by passing a block to `SumsUp.define`:

```ruby
Drink = SumsUp.define(:water, lemonade: :size, coffee: [:temperature, :size]) do
  def price_in_cents
    match do |m|
      m.water 0
      m.lemonade { |size| size.match(small: 350, large: 450) }
      m.coffee { |size, _temperature| size.match(small: 295, large: 395) }
    end
  end
end

Drink.water.price_in_cents
# => 0

Drink.lemonade(Size.small).price_in_cents
# => 350

Drink.coffee(Size.large, Temperature.hot).price_in_cents
# => 395
```

This syntax also supports class methods and constants:

```ruby
Size = SumsUp.define(:small, :large) do
  SMALL_STRING = 'Small'.freeze
  LARGE_STRING = 'Large'.freeze

  def self.parse(str)
    case str
    when SMALL_STRING
      small
    when LARGE_STRING
      large
    else
      raise ArgumentError, "Invalid size: #{str}"
    end
  end
end

Size::SMALL_STRING
# => 'Small'

Size::LARGE_STRING
# => 'Large'

Size.parse('Small')
# => #<variant Size::Small>

Size.parse('Trenta')
# => ArgumentError: Invalid size: Trenta
```

## Variant Instance Methods

In addition to user-defined methods, `#inspect`, and `#==`, variant instances come with convenience methods for accessing and updating members.

### Getters

Fetch a variant's members by name:

```ruby
coffee = Drink.coffee(Size.small, Temperature.hot)
coffee.size
# => #<variant Size::Small>

coffee.temperature
# => #<variant Temperature::Hot>

lemonade = Drink.lemonade(Size.large)
lemonade.size
# => #<variant Size::Large>

# Lemonade does not have a 'temperature' member.
lemonade.temperature
# => NoMethodError: undefined method `temperature' for #<variant Drink::Lemonade size=#<variant Size::Large>>
```

Another way to access members is `#[]`:

```ruby
coffee = Drink.coffee(Size.small, Temperature.iced)
coffee[:size]
# => #<variant Size::Small>

# #[] works with Strings as well.
lemonade = Drink.lemonade(Size.large)
lemonade['size']
# => #<variant Size::Large>

# #[] will raise given an invalid member.
lemonade[:temperature]
# => NameError: No member 'temperature' in variant lemonade.
```

### Setters

Members may also be updated by name:

```ruby
coffee = Drink.coffee(Size.small, Temperature.hot)
coffee.temperature = Temperature.iced # Oh, sorry, could you make that iced?
coffee.temperature
# => #<variant Temperature::Iced>
```

`#[]=` can also update a member:

```ruby
lemonade = Drink.lemonade(Size.large)
lemonade['size'] = Size.small # Oh, a large is 32oz?
lemonade.size
# => #<variant Size::Small>

lemonade[:temperature] = Temperature.hot # Sorry, we don't do that here.
# => NameError: No member 'temperature' in variant lemonade.
```

### `#attributes`

Get a variant's members as a `Hash`:

```ruby
Drink.water.attributes
# => {}

Drink.lemonade(Size.small).attributes
# => { size: #<variant Size::Small> }

Drink.coffee(Size.large, Temperataure.iced).attributes
# => { size: #<variant Size::Large> , temperature: #<variant Temperature::Iced> }
```

### `#to_h`

Return the variant as a `Hash`:

```ruby
Drink.water.to_h
# => { water: {} }

Drink.lemonade(Size.small).to_h
# => { lemonade: { size: #<variant Size::Small> } }

Drink.coffee(Size.large, Temperataure.iced).to_h
# => { coffee: { size: #<variant Size::Large> , temperature: #<variant Temperature::Iced> } }
```

Use `include_root: false` to make this method behave like `#attributes`:

```ruby
Drink.water.to_h(include_root: false)
# => {}

Drink.lemonade(Size.small).to_h(include_root: false)
# => { size: #<variant Size::Small> }

Drink.coffee(Size.large, Temperataure.iced).to_h(include_root: false)
# => { size: #<variant Size::Large>, temperature: #<variant Temperature::Iced> }
```

### `#members`

Get a variant's members in the order they were in when passed into the initializer:

```ruby
Drink.water.members
# => []

Drink.lemonade(Size.small).members
# => [#<variant Size::Small>]

Drink.coffee(Size.large, Temperataure.iced).members
# => [#<variant Size::Large>, #<variant Temperature::Iced>]
```

## A Note on Mutability

All variants without members are memoized and frozen by default.
In our running example calling `Size.small`, `Size.large`, `Temperature.hot`, `Temperature.iced`, and `Drink.water` would all return memoized and frozen objects, but `Drink.lemonade(size)` and `Drink.coffee(size, temperature)` would not.
This helps reduce the memory footprint of the gem, but makes it so that we cannot write to instance variables within the class.

Let's say that we wanted to memoize the result of `#price_in_cents` like so:

```ruby
Drink = SumsUp.define(:water, lemonade: :size, coffee: [:temperature, :size]) do
  def price_in_cents
    @price_in_cents ||= match do |m|
      m.water 0
      m.lemonade { |size| size.match(small: 350, large: 450) }
      m.coffee { |size, _temperature| size.match(small: 295, large: 395) }
    end
  end
end
```

The `Drink.lemonade` and `Drink.coffee` variants would be unaffected because they are not frozen:

```ruby
Drink.lemonade(Size.large).price_in_cents
# => 450

Drink.coffee(Size.small, Temperature.hot).price_in_cents
# => 295
```

However, `Drink.water` will raise because it is frozen:

```ruby
Drink.water.price_in_cents
# => RuntimeError: can't modify frozen Drink::Water
```

In general, it's better to find solutions which don't require state to be tracked within data types, but if mutability is absolutely required, we can work around this by passing `memo: false` to the memberless variant's initializer:

```ruby
Drink.water(memo: false).price_in_cents
# => 0
```

This will work with any memberless variant:

```ruby
Size.small(memo: false)
# => #<variant Size::Small>

Size.large(memo: false)
# => #<variant Size::Large>

Temperature.hot(memo: false)
# => #<variant Temperature::Hot>

Temperature.iced(memo: false)
# => #<variant Temperature::Iced>
```

## Maybes

`SumsUp::Maybe` represents a value which may or may not be present.

Variants:

```ruby
SumsUp::Maybe.nothing
# => #<variant SumsUp::Maybe::Nothing>

SumsUp::Maybe.just(1)
# => #<variant SumsUp::Maybe::Just value=1>
```

Predicates:

```ruby
SumsUp::Maybe.nothing.nothing?
# => true

SumsUp::Maybe.nothing.just?
# => false

SumsUp::Maybe.just(1).nothing?
# => false

SumsUp::Maybe.just(2).just?
# => true
```

Pattern matching:

```ruby
def maybe_to_int(maybe)
  maybe.match do |m|
    m.nothing 0
    m.just { |num| num }
  end
end

maybe_to_int(SumsUp::Maybe.nothing)
# => 0

maybe_to_int(SumsUp::Maybe.just(1))
# => 1
```

`SumsUp::Maybe.of` builds a `SumsUp::Maybe` from a value which may be `nil`:

```ruby
SumsUp::Maybe.of(nil)
# => #<variant SumsUp::Maybe::Nothing>

SumsUp::Maybe.of('cat')
# => #<variant SumsUp::Maybe::Just value="cat">

SumsUp::Maybe.of(false)
# => #<variant SumsUp::Maybe::Just value=false>
```

`SumsUp::Maybe#map` applies a function to the value if it's present:

```ruby
SumsUp::Maybe.nothing.map { |x| x + 1 }
# => #<variant SumsUp::Maybe::Nothing>

SumsUp::Maybe.just(3).map { |x| x + 1 }
# => #<variant SumsUp::Maybe::Just value=4>
```

`SumsUp::Maybe#or_else` returns the wrapped value, or a default if it's not present:

```ruby
SumsUp::Maybe.nothing.or_else(1)
# => 1

SumsUp::Maybe.nothing.or_else { 2 }
# => 2

SumsUp::Maybe.just(3).or_else(4)
# => 3

SumsUp::Maybe.just(4).or_else { 5 }
# => 4
```

## Results

`SumsUp::Result` represents a successful result or an error.

Variants:

```ruby
SumsUp::Result.failure('update failed')
# => #<variant SumsUp::Maybe::Failure error="update failed">

SumsUp::Maybe.success('request payload')
# => #<variant SumsUp::Maybe::Just value="request payload">
```

Predicates:

```ruby
SumsUp::Result.failure(false).failure?
# => true

SumsUp::Result.failure(0).success?
# => false

SumsUp::Result.success(true).failure?
# => false

SumsUp::Result.success(1).success?
# => true
```

Pattern matching:

```ruby
def flip_result(result)
  result.match do |m|
    m.failure { |error| SumsUp::Result.success(error) }
    m.success { |value| SumsUp::Result.failure(value) }
  end
end

flip_result(SumsUp::Result.success('yay'))
# => #<variant SumsUp::Result::Failure error="yay">

flip_result(flip_result(SumsUp::Result.failure('boo')))
# => #<variant SumsUp::Result::Failure error="boo">
```

`SumsUp::Result.from_block` converts a block which may raise into a `SumsUp::Result`:

```ruby
SumsUp::Result.from_block { raise 'unexpected error' }
# => #<variant SumsUp::Result::Failure error=#<RuntimeError: unexpected error>>

SumsUp::Result.from_block { 'good result' }
# => #<variant SumsUp::Result::Success value="good result">
```

`SumsUp::Result#map` applies a function to the successful values:

```ruby
SumsUp::Result.failure('sorry kid').map { |x| x + ', nothing personal' }
# => #<variant SumsUp::Result::Failure error="sorry kid">

SumsUp::Result.success(10).map { |x| x * 2 }
# => #<variant SumsUp::Result::Success value=20>
```

`SumsUp::Result#map_failure` applies a function to the failure errors:

```ruby
SumsUp::Result.failure('sorry kid').map_failure { |x| x + ', nothing personal' }
# => #<variant SumsUp::Result::Failure error="sorry kid, nothing personal">

SumsUp::Result.success(10).map_failure { |x| x * 2 }
# => #<variant SumsUp::Result::Success value=10>
```

## Why?

Some of these examples may seem odd if you're not familiar with sum types.
If we were instead using the tools provided by Ruby, we might use a boolean to determine whether a given drink is a small or large, hot or cold.
This would work, of course, so why use sum types?

Let's illustrate by defining `OtherDrink` using a `Struct` with booleans for `is_hot` and `is_large`

```ruby
OtherDrink = Struct.new(:type, :is_hot, :is_large) do
  private_class_method(:new)

  def self.water
    new(:water, false, false)
  end

  def self.lemonade(is_large)
    new(:lemonade, false, is_large)
  end

  def self.coffee(is_hot, is_large)
    new(:coffee, is_hot, is_large)
  end
end

OtherDrink.water
# => #<struct OtherDrink type=:water, is_hot=false, is_large=false>

OtherDrink.lemonade(true)
# => #<struct OtherDrink type=:lemonade, is_hot=false, is_large=true>

OtherDrink.coffee(true, false)
# => #<struct OtherDrink type=:water, is_hot=true, is_large=false>
```

`OtherDrink` can do all of the things that `Drink` can, but its API is less descriptive.
For example, to represent a small hot coffee using `OtherDrink`, we would call `OtherDrink.coffee(true, false)`.
In the `sums_up`-defined `Drink`, we'd instead call `Drink.coffee(Size.small, Temperature.hot)`.
This may seem a bit contrived, but using a sum type instead of a boolean can help make our code more declarative and self-documenting.

Sum types can also provide extensibility when project requirements change.
If our example cafe started carrying medium coffees and lemonades, we only need update our `Size` type to accomodate that:

```ruby
Size = SumsUp.define(:small, :medium, :large)

Drink.coffee(Size.medium, Temperature.iced)
# => #<variant Drink::Coffee size=#<variant Size::Medium> temperature=#<variant Temperature::Iced>>
```

How would we handle this if we were using `OtherDrink`?
A boolean is no longer suitable given that we need to track three different possible options, so we would probably end up using symbols like `:small`, `:medium`, and `:large`.
This will work, but refactoring will likely be more difficult.

With `Size`, after adding `Size.medium`, we find our `Size#match` calls, ensure that we're handling `Size.medium`, and we're done.
With `OtherDrink`'s `:small`, `:medium`, and `:large` symbols, we would need to refactor the code which uses `OtherDrink.is_large` to instead match on symbols, and we would also introduce the possibility that a drink's size is invalid.
This can lead to us writing a lot of checks for invalid data which may or may not be necessary.
Sum types will do this for you; there's no way to make an invalid `Size`, so we know that our `#match` calls are categorically handling all cases.

## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `bundle exec rake spec` to run the tests.
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nahiluhmot/sums_up.
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/nahiluhmot/sums_up/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SumsUp projects codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/nahiluhmot/sums_up/blob/master/CODE_OF_CONDUCT.md).
