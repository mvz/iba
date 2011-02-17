require File.expand_path('test_helper.rb', File.dirname(__FILE__))

# Test how the combinator displays the parsed block contents.
class DisplayTest < Test::Unit::TestCase
  def test_empty_combinator
    assert_equal "nil", combinator { }.to_s
  end

  def test_literal_number
    assert_equal "23", combinator { 23 }.to_s
  end

  def test_literal_string
    assert_equal "\"aa\"", combinator { "aa" }.to_s
  end

  def test_method_calls
    assert_equal "foo", combinator { foo }.to_s
    assert_equal "foo.foo", combinator { foo.foo }.to_s
    assert_equal "foo.foo(1)", combinator { foo.foo 1 }.to_s
    assert_equal "foo(1)", combinator { foo 1 }.to_s
    assert_equal "foo(bar)", combinator { foo bar }.to_s
    assert_equal "foo(1).bar", combinator { foo(1).bar }.to_s
    assert_equal "foo.foo.foo", combinator { foo.foo.foo }.to_s
    assert_equal "foo(bar.baz)", combinator { foo bar.baz }.to_s
  end

  def test_operators
    assert_equal "(foo + 1)", combinator { foo + 1 }.to_s
    assert_equal "(foo - 1)", combinator { foo - 1 }.to_s
  end

  def test_operator_equals
    assert_equal "(foo == 1)", combinator { foo == 1 }.to_s
  end

  def test_array_index
    assert_equal "foo[1]", combinator { foo[1] }.to_s
  end

  def test_to_s_method
    assert_equal "foo.to_s", combinator { foo.to_s }.to_s
  end

  def test_operator_unary_minus
    assert_equal "-foo", combinator { -foo }.to_s
  end

  def test_operator_if_wont_work
    assert_equal "bar", combinator { foo ? bar : baz }.to_s
  end
end
