require 'test/unit'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'iba'

class Test::Unit::TestCase
  include Iba::BlockAssertion

  def combinator &blk
    Iba::Combinator.new(&blk)
  end
end
