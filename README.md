# Iba

by Matijs van Zuijlen

## Description

Introspective Block Assertions

## Features/Problems

* Write assertions as a (one-expression) block
* Assertion message deconstructs the block's expression.
* Not done yet.

## Synopsis

```ruby
# In your test helper:
require 'iba'
class Test::Unit::TestCase
  include Iba::BlockAssertion
end

# In your test:
foo = 24
assert { foo == 23 } # => "(foo == 23) is false
                     #     foo is 24."
```

## Details

Iba provides an assert method that takes a block. If the block returns
false, it will try to construct an insightful error message based on the
contents of the block.

Iba's functionality is inspired by [Wrong], but doesn't use an external
Ruby parser. This means it will work in contexts where Wrong does not
(generated code, on the command line). It also means there are more limits
to the contents of the block.

Current limits:

* Only single-expression blocks are supported.
* The expression must start with a method-like identifier or an instance
  variable (like `foo`  or `@foo`, but not `Foo` or `23`). In practice,
  this produces quite natural results.
* Local and instance variables whose names start with an underscore should
  not be used inside the block.

Iba's implementation is inspired by [Arlo], a generic combinator library
for Python. The implementation of Arlo is now [on github][arlo-code].

## Install

```
gem install iba
```

<!-- Links -->

[Wrong]: https://github.com/sconover/wrong
[Arlo]: https://web.archive.org/web/20081228090759/http://withoutane.com:80/rants/2008/12/arlo-generic-combinators-for-python
[arlo-code]: https://github.com/tangentstorm/workshop/blob/main/code/arlo.py

## Licence

See the LICENSE file
