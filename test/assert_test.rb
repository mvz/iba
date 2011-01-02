require File.expand_path('test_helper.rb', File.dirname(__FILE__))

# Test behavior of overridden assert method.
class AssertTest < Test::Unit::TestCase
  def test_simple_assert
    assert { true }
  end

  def test_simple_failing_assert
    begin
      assert { false }
    rescue Exception => e
      assert_equal "false is false", e.message
    end
  end

  def test_operator_equals_assert
    foo = 24
    begin
      assert { foo == 23  }
    rescue Exception => e
      assert_equal "(foo == 23) is false\nfoo is 24", e.message
    end
  end
end

