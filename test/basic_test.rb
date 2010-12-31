require File.expand_path('test_helper.rb', File.dirname(__FILE__))
require 'combinator'

class BasicTest < Test::Unit::TestCase
  context "The created combinator" do
    context "for nothing" do
      setup do
	@cmb = combinator { }
      end
      should "give a value of nil" do
	assert_equal nil, @cmb.call
      end
      should "display as the empty string" do
	assert_equal "", @cmb.to_s
      end
    end
  end
end
