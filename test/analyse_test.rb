# frozen_string_literal: true

require_relative "test_helper"

# Test how the combinator analyses the parsed block contents.
class AnalyseTest < Test::Unit::TestCase
  def test_empty_block
    assert_equal "nil is nil", combinator {}.analyse
  end

  def test_variable
    foo = 23
    assert_equal "foo is 23", combinator { foo }.analyse
  end

  def test_operator_equals
    foo = 42
    bar = 23
    result = combinator { foo == bar }.analyse
    assert_equal "(foo == bar) is false\nfoo is 42, bar is 23", result
  end

  def test_operator_equals_literal
    foo = 42
    result = combinator { foo == 23 }.analyse
    assert_equal "(foo == 23) is false\nfoo is 42", result
  end

  def test_operator_equals_array_literal
    foo = [1, "bar"]
    result = combinator { foo == [2, "baz"] }.analyse
    assert_equal "(foo == [2, \"baz\"]) is false\nfoo is [1, \"bar\"]", result
  end

  def test_string_variable
    foo = "blub"
    assert_equal 'foo is "blub"', combinator { foo }.analyse
  end

  def test_array_variable
    foo = [1, 2]
    assert_equal "foo is [1, 2]", combinator { foo }.analyse
  end

  def test_object_variable
    foo = Object.new
    insp = foo.inspect
    assert_equal "foo is #{insp}", combinator { foo }.analyse
  end

  def test_literal
    assert_equal "23 is 23", combinator { 23 }.analyse
  end

  def test_instance_variable
    @foo = 23
    assert_equal "@foo is 23", combinator { @foo }.analyse
  end

  def test_instance_variable_method_call
    @foo = 23
    assert_equal "(@foo == 23) is true\n@foo is 23", combinator { @foo == 23 }.analyse
  end

  def test_instance_variable_as_argument_of_operator
    @foo = 23
    assert_equal "(23 + @foo) is 46", combinator { 23 + @foo }.analyse
  end

  def test_complex_subexpressions
    @foo = 23
    bar = 42
    baz = [42]
    result = combinator { (@foo + baz.first) == (bar + 23) }.analyse
    assert_equal \
      "((@foo + baz.first) == (bar + 23)) is true\n" \
      "(@foo + baz.first) is 65, (bar + 23) is 65",
      result
  end
end
