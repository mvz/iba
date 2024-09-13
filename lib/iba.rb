# frozen_string_literal: true

require_relative "iba/version"

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
      str = "#{self} is #{call.inspect}"
      sub = expression._display_subexpressions(@block.binding)
      str << "\n#{sub}" if sub
      str
    end
  end

  class BaseExpression
    def method_missing(method, *args)
      # FIXME: Remove to_s once support for Ruby < 2.7 is dropped
      super if method.to_s.start_with? "_"
      MethodCallExpression.new self, method, args
    end

    def respond_to_missing?(method)
      # FIXME: Remove to_s once support for Ruby < 2.7 is dropped
      return super if method.to_s.start_with? "_"

      true
    end

    def to_s
      method_missing :to_s
    end

    def ==(other)
      method_missing :==, other
    end

    def !=(other)
      method_missing :!=, other
    end

    def _wrap(arg)
      if arg.is_a? BaseExpression
        arg
      else
        LiteralExpression.new arg
      end
    end

    def _display(_bnd)
      nil
    end

    def _display_subexpressions(_bnd)
      nil
    end

    # Handle numeric operator coersion
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
        # FIXME: Remove to_s once support for Ruby < 2.7 is dropped
        next if v.to_s.start_with? "@_"

        instance_variable_set v, Iba::InstanceVariableExpression.new(v.to_sym)
      end
    end

    def _override_local_variables(vars, bnd)
      vars.each do |v|
        # FIXME: Remove to_s once support for Ruby < 2.7 is dropped
        next if v.to_s.start_with? "_"

        bnd.local_variable_set "_#{v}", bnd.local_variable_get(v)
        bnd.local_variable_set v, LocalVariableExpression.new(v.to_sym)
      end
    end

    def _restore_local_variables(vars, bnd)
      vars.each do |v|
        # FIXME: Remove to_s once support for Ruby < 2.7 is dropped
        next if v.to_s.start_with? "_"

        bnd.local_variable_set v, bnd.local_variable_get("_#{v}")
      end
    end

    def _to_s
      ""
    end
  end

  class LiteralExpression < BaseExpression
    def initialize(val)
      super()
      @value = val
    end

    def _to_s
      @value.inspect
    end

    def _evaluate(_bnd)
      @value
    end
  end

  class DisplayableExpression < BaseExpression
    def _display(bnd)
      str = _to_s
      value = _evaluate(bnd).inspect
      "#{str} is #{value}"
    end
  end

  class InstanceVariableExpression < DisplayableExpression
    def initialize(ivar_name)
      super()
      @_ivar_name = ivar_name
    end

    def _to_s
      @_ivar_name.to_s
    end

    def _evaluate(bnd)
      bnd.receiver.instance_variable_get @_ivar_name
    end
  end

  class LocalVariableExpression < DisplayableExpression
    def initialize(lvar_name)
      super()
      @_lvar_name = lvar_name
    end

    def _to_s
      @_lvar_name.to_s
    end

    def _evaluate(bnd)
      bnd.local_variable_get @_lvar_name
    end
  end

  class MethodCallExpression < DisplayableExpression
    attr_reader :_method, :_reciever, :_args

    def initialize(reciever, methodname, args)
      super()
      @_reciever = reciever
      @_method = methodname
      @_args = args.map { |a| _wrap(a) }
    end

    def _to_s
      if @_method == :[]
        _index_to_s
      elsif _method_is_operator?
        _operator_to_s
      else
        _regular_method_to_s
      end
    end

    def _evaluate(bnd)
      rcv = @_reciever._evaluate(bnd)
      args = @_args.map { |arg| arg._evaluate(bnd) }
      rcv.send @_method, *args
    end

    def _display_subexpressions(bnd)
      rcv = @_reciever._display(bnd)
      args = @_args.map { |arg| arg._display(bnd) }
      [rcv, *args].compact.join(", ")
    end

    private

    def _receiver_s
      @_reciever._to_s
    end

    def _args_s
      @_args.map { |a| a.respond_to?(:_to_s) ? a._to_s : a.to_s }
    end

    def _index_to_s
      "#{_receiver_s}[#{_args_s[0]}]"
    end

    def _operator_to_s
      case @_args.length
      when 0
        "#{@_method.to_s.sub(/@$/, '')}#{_receiver_s}"
      when 1
        "(#{_receiver_s} #{@_method} #{_args_s.first})"
      else
        raise NotImplementedError
      end
    end

    def _regular_method_to_s
      rcv = _receiver_s
      str = rcv == "" ? +"" : "#{rcv}."
      str << @_method.to_s
      str << "(#{_args_s.join(', ')})" unless @_args.empty?
      str
    end

    def _method_is_operator?
      @_method.to_s !~ /^[a-z]/
    end
  end

  module BlockAssertion
    def assert(*args, &block)
      if block
        if yield
          assert_block("true") { true }
        else
          msg = args.empty? ? "" : "#{args.first}.\n"
          ana = Combinator.new(&block).analyse
          assert_block("#{msg}#{ana}.") { false }
        end
      else
        test, msg = *args
        super(test, msg)
      end
    end
  end
end
