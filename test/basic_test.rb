require File.expand_path('test_helper.rb', File.dirname(__FILE__))
require 'combinator'

class BasicTest < Test::Unit::TestCase
  def test_combinator
    assert_equal "", combinator { }.to_s
    assert_equal "foo", combinator { foo }.to_s
    assert_equal "foo.foo", combinator { foo.foo }.to_s
    assert_equal "foo.foo(1)", combinator { foo.foo 1 }.to_s
    assert_equal "foo(1)", combinator { foo 1 }.to_s
    assert_equal "foo(bar)", combinator { foo bar }.to_s
    assert_equal "foo(1).bar", combinator { foo(1).bar }.to_s
    assert_equal "foo.foo.foo", combinator { foo.foo.foo }.to_s
  end
end
