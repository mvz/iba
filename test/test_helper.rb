# frozen_string_literal: true

require "test/unit"
require "iba"

class Test::Unit::TestCase
  include Iba::BlockAssertion

  def combinator(&blk)
    Iba::Combinator.new(&blk)
  end
end
