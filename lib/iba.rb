# frozen_string_literal: true

module Iba
  class Combinator
    def initialize(&blk)
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
      str = +"#{self} is #{call.inspect}"
      if expression.class == MethodCallExpression && expression._method == :==
        lft = expression._reciever
        rgt = expression._args.first
        exprs = [lft, rgt].map { |e| display_subexpression e }.compact
        str << "\n"
        str << exprs.join(", ")
      end
      str
    end

    private

    def display_subexpression(expr)
      if expr.class == LiteralExpression
        nil
      else
        str = expr._to_s
        value = expr._evaluate(@block.binding).inspect
        "#{str} is #{value}"
      end
    end
  end

  class BaseExpression
    def method_missing(method, *args)
      super if /^_/.match?(method.to_s)
      MethodCallExpression.new self, method, args
    end

    def respond_to_missing?(method)
      return false if /^_/.match?(method.to_s)

      true
    end

    def to_s
      method_missing :to_s
    end

    def ==(other)
      method_missing :==, other
    end

    def _wrap(arg)
      if arg.is_a? BaseExpression
        arg
      else
        LiteralExpression.new arg
      end
    end

    def coerce(other)
      [_wrap(other), self]
    end
  end

  class EmptyExpression < BaseExpression
    def _parse(&blk)
      bnd = blk.binding

      vars = bnd.local_variables
      ivars = bnd.receiver.instance_variables

      _override_instance_variables ivars

      _override_local_variables vars, bnd

      result = instance_eval(&blk)
      result = _wrap(result)

      _restore_local_variables vars, bnd

      result
    end

    def _override_instance_variables(vars)
      vars.each do |v|
        next if /^@_/.match?(v)

        instance_variable_set v, Iba::InstanceVariableExpression.new(v.to_sym)
      end
    end

    def _override_local_variables(vars, bnd)
      vars.each do |v|
        next if /^_/.match?(v)

        bnd.local_variable_set "_#{v}", bnd.local_variable_get(v)
        bnd.local_variable_set v, LocalVariableExpression.new(v.to_sym)
      end
    end

    def _restore_local_variables(vars, bnd)
      vars.each do |v|
        next if /^_/.match?(v)

        bnd.local_variable_set v, bnd.local_variable_get("_#{v}")
      end
    end

    def _to_s
      ""
    end
  end

  class LiteralExpression < BaseExpression
    def initialize(val)
      @value = val
    end

    def _to_s
      @value.inspect
    end

    def _evaluate(_bnd)
      @value
    end
  end

  class InstanceVariableExpression < BaseExpression
    def initialize(ivar_name)
      @_ivar_name = ivar_name
    end

    def _to_s
      @_ivar_name.to_s
    end

    def _evaluate(bnd)
      bnd.receiver.instance_variable_get @_ivar_name
    end
  end

  class LocalVariableExpression < BaseExpression
    def initialize(lvar_name)
      @_lvar_name = lvar_name
    end

    def _to_s
      @_lvar_name.to_s
    end

    def _evaluate(bnd)
      bnd.local_variable_get @_lvar_name
    end
  end

  class MethodCallExpression < BaseExpression
    attr_reader :_method, :_reciever, :_args

    def initialize(reciever, methodname, args)
      @_reciever = reciever
      @_method = methodname
      @_args = args.map { |a| _wrap(a) }
    end

    def _to_s
      rcv = @_reciever._to_s
      args = @_args.map { |a| a.respond_to?(:_to_s) ? a._to_s : a.to_s }

      if @_method == :[]
        "#{rcv}[#{args[0]}]"
      elsif _method_is_operator?
        case @_args.length
        when 0
          "#{@_method.to_s.sub(/@$/, '')}#{rcv}"
        when 1
          "(#{rcv} #{@_method} #{args.first})"
        else
          raise NotImplementedError
        end
      else
        str = rcv == "" ? +"" : +"#{rcv}."
        str << @_method.to_s
        str << "(#{args.join(', ')})" unless @_args.empty?
        str
      end
    end

    def _evaluate(bnd)
      rcv = @_reciever._evaluate(bnd)
      args = @_args.map { |arg| arg._evaluate(bnd) }
      rcv.send @_method, *args
    end

    private

    def _method_is_operator?
      @_method.to_s !~ /^[a-z]/
    end
  end

  module BlockAssertion
    def assert(*args, &block)
      if block_given?
        if yield
          assert_block("true") { true }
        else
          msg = args.empty? ? "" : "#{args.first}.\n"
          ana = Combinator.new(&block).analyse
          assert_block("#{msg}#{ana}.") { false }
        end
      else
        test, msg = *args
        super test, msg
      end
    end
  end
end
