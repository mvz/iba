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
  def method_missing method, *args
    return MethodCallExpression.new nil, method.to_s, args
  end
end

class MethodCallExpression
  def initialize reciever, methodname, args
    @reciever = reciever
    @name = methodname
    @args = args
  end

  def to_s
    str = @reciever.nil? ? "" : "#{@reciever}."
    str << @name
    unless @args.empty?
      str << "(#{@args.join(', ')})"
    end
    str
  end

  def method_missing method, *args
    return MethodCallExpression.new self, method.to_s, args
  end
end

class Object
  def combinator &blk
    return Combinator.new(&blk)
  end
end
