class Combinator
  def initialize &blk
    @block = blk
  end

  def call
    @block.call
  end

  def to_s
    if expression.respond_to? :_to_s
      expression._to_s
    else
      expression.to_s
    end
  end

  def expression
    @expression ||= EmptyExpression.new.instance_eval(&@block)
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

  def _to_s
    rcv = @reciever.nil? ? "" : @reciever._to_s
    args = @args.map {|a| a.respond_to?(:_to_s) ? a._to_s : a.to_s }

    if @method == :[]
      "#{rcv}[#{args[0]}]"
    elsif method_is_operator?
      raise NotImplementedError if @args.length != 1
      "(#{rcv} #{@method} #{args[0]})"
    else
      str = @reciever.nil? ? "" : "#{rcv}."
      str << @method.to_s
      unless @args.empty?
	str << "(#{args.join(', ')})"
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

  def to_s
    method_missing :to_s
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
