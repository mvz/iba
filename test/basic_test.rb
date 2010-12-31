require File.expand_path('test_helper.rb', File.dirname(__FILE__))
require 'combinator'

class BasicTest < Test::Unit::TestCase
  def test_combinator
    assert_equal "", combinator { }.to_s
    assert_equal "foo", combinator { foo }.to_s
    assert_equal "foo.foo", combinator { foo.foo }.to_s
    assert_equal "foo.foo(1)", combinator { foo.foo 1 }.to_s
  end
end
