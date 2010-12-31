class Combinator
  def call
    nil
  end

  def to_s
    ""
  end
end

class Object
  def combinator
    return Combinator.new
  end
end
