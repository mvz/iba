require File.expand_path('test_helper.rb', File.dirname(__FILE__))

# Test how the combinator analyses the parsed block contents.
class AnalyseTest < Test::Unit::TestCase
  def test_empty_combinator
    assert_equal "nil is nil", combinator { }.analyse
  end
end

