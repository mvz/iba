require File.expand_path('test_helper.rb', File.dirname(__FILE__))

# Test how the combinator calls the passed block.
class CallTest < Test::Unit::TestCase
  def test_empty_combinator
    assert_equal nil, combinator { }.call
  end

  def test_variable
    foo = 23
    assert_equal 23, combinator { foo }.call
  end

  def test_operator_call
    foo = 23
    assert_equal true, combinator { foo == 23 }.call
  end
end
