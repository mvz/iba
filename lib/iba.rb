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
      if expression.class == MethodCallExpression and expression._method == :==
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
        "#{str} is #{eval(str, @block.binding).inspect}"
      end
    end

  end

  class EmptyExpression
    def method_missing method, *args
      return MethodCallExpression.new self, method, args
    end

    def _parse &blk
      b = blk.binding

      vars = eval 'local_variables', b
      ivars = eval 'instance_variables', b

      _override_instance_variables ivars

      _override_local_variables vars, b

      result = instance_eval(&blk)
      unless result.class == MethodCallExpression
        result = LiteralExpression.new(result)
      end

      _restore_local_variables vars, b

      result
    end

    def _override_instance_variables vars
      vars.each do |v|
        next if v =~ /^@_/
        eval "#{v} = Iba::MethodCallExpression.new(Iba::EmptyExpression.new, :#{v}, [])"
      end
    end

    def _override_local_variables vars, b
      vars.each do |v|
        next if v =~ /^_/
        eval "_#{v} = #{v}", b
        eval "#{v} = Iba::MethodCallExpression.new(Iba::EmptyExpression.new, :#{v}, [])", b
      end
    end

    def _restore_local_variables vars, b
      vars.each do |v|
        next if v =~ /^_/
        eval "#{v} = _#{v}", b
      end
    end

    def _to_s
      ''
    end
  end

  class LiteralExpression
    def initialize val
      @value = val
    end

    def _to_s
      @value.inspect
    end
  end

  class MethodCallExpression
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
        unless @_args.empty?
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
      @_method.to_s !~ /^[a-z]/
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

  module BlockAssertion
    if RUBY_VERSION < '1.9'

      def assert *args
        if block_given?
          if yield
            assert_block('true') { true }
          else
            msg = args.empty? ? '' : args.first
            ana = Combinator.new(&Proc.new).analyse
            assert_block(build_message msg, "#{ana}.") { false }
          end
        else
          super
        end
      end

    else

      def assert *args
        if block_given?
          if yield
            assert_block('true') { true }
          else
            msg = args.empty? ? '' : args.first
            ana = Combinator.new(&Proc.new).analyse
            assert_block(message(msg) { ana }) { false }
          end
        else
          test, msg = *args
          case msg
          when nil, String
            msg = message(msg) { '<false> is not true' }
          end
          super test, msg
        end
      end

    end
  end
end
