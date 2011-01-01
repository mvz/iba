require File.expand_path('test_helper.rb', File.dirname(__FILE__))
require 'combinator'

# Test how the combinator displays the parsed block contents.
class CallTest < Test::Unit::TestCase
  def test_empty_combinator
    assert_equal nil, combinator { }.call
  end

  def test_method_calls
    foo = 23
    assert_equal 23, combinator { foo }.call
  end
end

