module Iba
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
      str = "#{self} is #{call.inspect}"
      if expression.class == MethodCallExpression && expression._method == :==
        lft = expression._reciever
        rgt = expression._args.first
        exprs = [lft, rgt].map { |e| display_subexpression e }.compact
        str << "\n"
        str << exprs.join(', ')
      end
      str
    end

    private

    def display_subexpression expr
      if expr.class == LiteralExpression
        nil
      else
        str = expr._to_s
        "#{str} is #{@block.binding.eval(str).inspect}"
      end
    end
  end

  class BaseExpression
    def method_missing method, *args
      super if method.to_s =~ /^_/
      MethodCallExpression.new self, method, args
    end

    def respond_to_missing? method
      return false if method.to_s =~ /^_/
      true
    end

    def to_s
      method_missing :to_s
    end

    def == other
      method_missing :==, other
    end
  end

  class EmptyExpression < BaseExpression
    def _parse &blk
      b = blk.binding

      vars = b.local_variables
      ivars = b.receiver.instance_variables

      _override_instance_variables ivars

      _override_local_variables vars, b

      result = instance_eval(&blk)
      result = LiteralExpression.new(result) unless result.is_a? BaseExpression

      _restore_local_variables vars, b

      result
    end

    def _override_instance_variables vars
      vars.each do |v|
        next if v =~ /^@_/
        instance_variable_set v, Iba::InstanceVariableExpression.new(v.to_sym)
      end
    end

    def _override_local_variables vars, b
      vars.each do |v|
        next if v =~ /^_/
        b.local_variable_set "_#{v}", b.local_variable_get(v)
        b.local_variable_set v, Iba::MethodCallExpression.new(Iba::EmptyExpression.new,
                                                              v.to_sym,
                                                              [])
      end
    end

    def _restore_local_variables vars, b
      vars.each do |v|
        next if v =~ /^_/
        b.local_variable_set v, b.local_variable_get("_#{v}")
      end
    end

    def _to_s
      ''
    end
  end

  class LiteralExpression < BaseExpression
    def initialize val
      @value = val
    end

    def _to_s
      @value.inspect
    end
  end

  class InstanceVariableExpression < BaseExpression
    def initialize ivar_name
      @_ivar_name = ivar_name
    end

    def _to_s
      @_ivar_name.to_s
    end
  end

  class MethodCallExpression < BaseExpression
    attr_reader :_method, :_reciever, :_args

    def initialize reciever, methodname, args
      @_reciever = reciever
      @_method = methodname
      @_args = args.map { |a| _wrap(a) }
    end

    def _to_s
      rcv = @_reciever._to_s
      args = @_args.map { |a| a.respond_to?(:_to_s) ? a._to_s : a.to_s }

      if @_method == :[]
        "#{rcv}[#{args[0]}]"
      elsif method_is_operator?
        case @_args.length
        when 0
          "#{@_method.to_s.sub(/@$/, '')}#{rcv}"
        when 1
          "(#{rcv} #{@_method} #{args.first})"
        else
          raise NotImplementedError
        end
      else
        str = rcv == '' ? '' : "#{rcv}."
        str << @_method.to_s
        str << "(#{args.join(', ')})" unless @_args.empty?
        str
      end
    end

    def method_is_operator?
      @_method.to_s !~ /^[a-z]/
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

  module BlockAssertion
    def assert *args
      if block_given?
        if yield
          assert_block('true') { true }
        else
          msg = args.empty? ? '' : "#{args.first}.\n"
          ana = Combinator.new(&Proc.new).analyse
          assert_block("#{msg}#{ana}.") { false }
        end
      else
        test, msg = *args
        super test, msg
      end
    end
  end
end
