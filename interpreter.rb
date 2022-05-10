require_relative "./token_type"
require_relative "./token"
require_relative "./expr"
require_relative "./runtime_error"

class Interpreter < Visitor
  def initialize(lox)
    @lox = lox
  end

  def interpret(expr)
    begin
      value = evaluate(expr)
      puts value.to_s
    rescue LoxRuntimeError => e
      @lox.runtimeError(e)
    end
  end

  def evaluate(expr)
    expr.accept(self)
  end

  def visitBinaryExpr(expr)
    left = evaluate(expr.left)
    right = evaluate(expr.right)
    case expr.operator.type
    when TokenType::MINUS
      checkNumberOperands(expr.operator, left, right)
      return left - right
    when TokenType::SLASH
      checkNumberOperands(expr.operator, left, right)
      if right == 0
        raise LoxRuntimeError.new(expr.operator, "Can't divide by zero")
      end
      return left / right
    when TokenType::STAR 
      checkNumberOperands(expr.operator, left, right)
      return left * right
    when TokenType::PLUS
      if left.is_a?(Numeric) && right.is_a?(Numeric)
        return left + right
      end
      if left.is_a?(String) && right.is_a?(String)
        return left + right
      end
      raise LoxRuntimeError.new(expr.operator, 
        "Operands must be two numbers or two strings.")
    when TokenType::GREATER
      checkNumberOperands(expr.operator, left, right)
      return left > right 
    when TokenType::GREATER_EQUAL
      checkNumberOperands(expr.operator, left, right)
      return left >= right
    when TokenType::LESS
      checkNumberOperands(expr.operator, left, right)
      return left < right
    when TokenType::LESS_EQUAL
      checkNumberOperands(expr.operator, left, right)
      return left <= right
    when TokenType::BANG_EQUAL
      return !equal?(left, right)
    when TokenType::EQUAL_EQUAL
      return equal?(left, right)
    end
    # Unreachable.
  end

  def visitLiteralExpr(expr)
    expr.value
  end

  def visitGroupingExpr(expr)
    evaluate(expr.expression)
  end

  def visitUnaryExpr(expr)
    right = evaluate(expr.right)

    case expr.operator.type
    when TokenType::MINUS
      checkNumberOperand(expr.operator, right)
      return -right.to_f
    when TokenType::BANG
      return !truthy?(right)
    end

    # Unreachable
    return nil
  end

  def checkNumberOperand(operator, operand)
    return if operand.is_a? Numeric
    raise LoxRuntimeError.new(operator, "Operand must be a number")
  end

  def checkNumberOperands(operator, left, right)
    return if left.is_a?(Numeric) && right.is_a?(Numeric)
    raise LoxRuntimeError.new(operator, "Operands must be numbers")
  end

  def truthy?(value)
    # Lox follows Ruby rules and we are using so...
    value
  end

  def equal?(a, b)
    return true if a == nil && b == nil
    return false if a == nil

    return a == b
  end
end
