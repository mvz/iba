require File.expand_path('test_helper.rb', File.dirname(__FILE__))

# Test how the combinator analyses the parsed block contents.
class AnalyseTest < Test::Unit::TestCase
  def test_empty_block
    assert_equal "empty block", combinator { }.analyse
  end

  def test_variable
    foo = 23
    assert_equal "foo is 23", combinator { foo }.analyse
  end

  def test_operator_equals
    foo = 42
    bar = 23
    assert_equal "(foo == bar) is false\nfoo is 42, bar is 23",
      combinator { foo == bar }.analyse 
  end

  def test_operator_equals_literal
    foo = 42
    assert_equal "(foo == 23) is false\nfoo is 42",
      combinator { foo == 23 }.analyse 
  end

  def test_string_variable
    foo = "blub"
    assert_equal "foo is \"blub\"", combinator { foo }.analyse
  end

  def test_object_variable
    foo = Object.new
    insp = foo.inspect
    assert_equal "foo is #{insp}", combinator { foo }.analyse
  end
end

