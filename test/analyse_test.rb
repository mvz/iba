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
end

