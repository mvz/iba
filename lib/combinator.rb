class Combinator
  def initialize &blk
    @block = blk
  end

  def call
    @block.call
  end

  def to_s
    expression._to_s
  end

  def expression
    @expression ||= EmptyExpression.new._parse(&@block)
  end

  def analyse
    if expression._to_s == ""
      "empty block"
    else
      str = "#{self.to_s} is #{self.call.inspect}"
      if expression.class == MethodCallExpression and expression._method == :==
	b = @block.binding
	lft = expression._reciever
	rgt = expression._args.first
	exprs = [lft, rgt].map {|e| display_subexpression e}.compact
	str << "\n"
	str << exprs.join(", ")
      end
      str
    end
  end

  private

  def display_subexpression expr
    if expr.class == LiteralExpression
      nil
    else
      str = expr._to_s
      "#{str} is #{eval str, @block.binding}"
    end
  end

end

class EmptyExpression
  def method_missing method, *args
    return MethodCallExpression.new self, method, args
  end

  def _parse &blk
    b = blk.binding

    vars = eval "local_variables", b
    vars.each do |v|
      next if v =~ /^_/
      eval "_#{v} = #{v}", b
      eval "#{v} = MethodCallExpression.new(EmptyExpression.new, :#{v}, [])", b
    end

    result = self.instance_eval(&blk)
    unless result.class == MethodCallExpression
      result = LiteralExpression.new(result)
    end

    vars.each do |v|
      next if v =~ /^_/
      eval "#{v} = _#{v}", b
    end

    result
  end

  def _to_s
    ""
  end
end

class LiteralExpression
  def initialize val
    @value = val
  end

  def _to_s
    @value.to_s
  end
end

class MethodCallExpression
  OPERATORS = [:+]
  def initialize reciever, methodname, args
    @reciever = reciever
    @method = methodname
    @args = args.map {|a| _wrap(a)}
  end

  def _method
    @method
  end

  def _reciever
    @reciever
  end

  def _args
    @args
  end

  def _to_s
    rcv = @reciever._to_s
    args = @args.map {|a| a.respond_to?(:_to_s) ? a._to_s : a.to_s }

    if @method == :[]
      "#{rcv}[#{args[0]}]"
    elsif method_is_operator?
      case @args.length
      when 0
	"#{@method.to_s.sub(/@$/, '')}#{rcv}"
      when 1
	"(#{rcv} #{@method} #{args.first})"
      else
	raise NotImplementedError
      end
    else
      str = rcv == "" ? "" : "#{rcv}."
      str << @method.to_s
      unless @args.empty?
	str << "(#{args.join(', ')})"
      end
      str
    end
  end

  def method_missing method, *args
    super if method.to_s =~ /^_/
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

  private

  def _wrap arg
    if arg.class == MethodCallExpression
      arg
    else
      LiteralExpression.new arg
    end
  end
end

class Object
  def combinator &blk
    return Combinator.new(&blk)
  end
end