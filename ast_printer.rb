require_relative "./expr"
require_relative "./token_type"
require_relative "./token"

class AstPrinter < Visitor
  def print(expr)
    expr.accept(self)
  end

  def visitBinaryExpr(expr)
    parenthensize(expr.operator.lexeme, expr.left, expr.right)
  end

  def visitGroupingExpr(expr)
    parenthensize("group", expr.expression)
  end

  def visitLiteralExpr(expr)
    return "nil" unless expr.value 
    expr.value.to_s
  end

  def visitUnaryExpr(expr)
    parenthensize(expr.operator.lexeme, expr.right)
  end

  def parenthensize(name, *exprs)
    builder = []
    builder << "(" << name
    exprs.each do |expr|
      builder << " " << expr.accept(self)
    end
    builder << ")"
    builder.join
  end

  def AstPrinter.main
    expr = Binary.new(
      Unary.new(
        Token.new(TokenType::MINUS, "-", nil, 1),
        Literal.new(123)),
      Token.new(TokenType::STAR, "*", nil, 1),
      Grouping.new(
        Literal.new(45.67)))
    puts AstPrinter.new.print(expr)
  end
end

AstPrinter.main
