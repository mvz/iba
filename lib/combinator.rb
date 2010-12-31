class Combinator
  def initialize &blk
    @result = EmptyExpression.new.instance_eval(&blk)
  end

  def call
    nil
  end

  def to_s
    @result.to_s
  end
end

class EmptyExpression
  def method_missing method
    return IdentifierExpression.new method.to_s
  end
end

class IdentifierExpression
  def initialize name
    @name = name
  end
  def to_s
    @name
  end
  def method_missing method, *args
    return MethodCallExpression.new self, method.to_s, args
  end
end

class MethodCallExpression
  def initialize reciever, methodname, args
    @reciever = reciever
    @name = methodname
    @args = args
  end
  def to_s
    if @args.empty?
      "#{@reciever}.#{@name}"
    else
      "#{@reciever}.#{@name}(#{@args.join(', ')})"
    end
  end
end

class Object
  def combinator &blk
    return Combinator.new(&blk)
  end
end
