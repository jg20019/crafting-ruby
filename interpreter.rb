require_relative "./token_type"
require_relative "./token"
require_relative "./expr"

class Interpreter < Vistor
  def evaluate(expr)
    expr.accept(self)
  end

  def visitBinaryExpr(expr)
    left = evaluate(expr.left)
    right = evaluate(expr.right)
    case expr.operator.type
    when TokenType::MINUS
      return left - right
    when TokenType::SLASH
      return left / right
    when TokenType::STAR 
      return left * right
    when TokenType::PLUS
      if left.is_a? Numeric && right.is_a? Numeric
        return left + right
      end
      if left.is_a? String && right.is_a? String
        return left + right
      end
    when TokenType::GREATER
      return left > right 
    when TokenType::GREATER_EQUAL
      return left >= right
    when TokenType::LESS
      return left < right
    when TokenType::LESS_EQUAL
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
      return -right.to_f
    when TokenType::BANG
      return !truthy?(right)
    end

    # Unreachable
    return nil
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
