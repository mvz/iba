require 'test/unit'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'combinator'

class Test::Unit::TestCase 
  include BlockAssertion
end
