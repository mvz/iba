# frozen_string_literal: true

require_relative 'test_helper'

# Test behavior of overridden assert method.
class AssertTest < Test::Unit::TestCase
  def test_simple_assert
    assert { true }
  end

  def failing_block_assertion_test message, &block
    assert(&block)
  rescue Exception => e
    assert_equal message, e.message
  end

  def test_simple_failing_assert
    failing_block_assertion_test('false is false.') { false }
  end

  def test_operator_equals_assert
    foo = 24
    failing_block_assertion_test("(foo == 23) is false\nfoo is 24.") { foo == 23 }
  end

  def test_instance_variable_assert
    @foo = 24
    failing_block_assertion_test("(@foo == 23) is false\n@foo is 24.") { @foo == 23 }
  end

  # Special cases

  def test_assert_with_custom_message
    foo = false
    begin
      assert('We want foo') { foo }
    rescue Exception => e
      assert_equal "We want foo.\nfoo is false.", e.message
    end
  end

  def test_blockless_assert
    assert false
  rescue Exception => e
    assert_equal '<false> is not true.', e.message
  end

  def test_blockless_assert_with_custom_message
    assert false, 'We want the truth'
  rescue Exception => e
    assert_equal "We want the truth.\n<false> is not true.", e.message
  end
end
