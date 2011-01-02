require 'test/unit'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'combinator'

class Test::Unit::TestCase 
  def assert
    if block_given?
      if yield
	assert_block("true") { true }
      else
	assert_block("false") { false }
      end
    else
      super
    end
  end
end
