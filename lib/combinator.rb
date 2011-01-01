class Combinator
  def initialize &blk
    @block = blk
    @result = EmptyExpression.new.instance_eval(&blk)
  end

  def call
    @block.call
  end

  def to_s
    @result.to_s
  end
end

class EmptyExpression
  def method_missing method, *args
    return MethodCallExpression.new nil, method, args
  end
end

class MethodCallExpression
  OPERATORS = [:+]
  def initialize reciever, methodname, args
    @reciever = reciever
    @method = methodname
    @args = args
  end

  def to_s
    if @method == :[]
      "#{@reciever}[#{@args[0]}]"
    elsif method_is_operator?
      raise NotImplementedError if @args.length != 1
      "(#{@reciever} #{@method} #{@args[0]})"
    else
      str = @reciever.nil? ? "" : "#{@reciever}."
      str << @method.to_s
      unless @args.empty?
	str << "(#{@args.join(', ')})"
      end
      str
    end
  end

  def method_missing method, *args
    return MethodCallExpression.new self, method, args
  end

  def method_is_operator?
    @method.to_s !~ /^[a-z]/
  end

  def == other
    method_missing :==, other
  end
end

class Object
  def combinator &blk
    return Combinator.new(&blk)
  end
end
