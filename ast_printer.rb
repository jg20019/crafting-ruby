require_relative "./expr"
require_relative "./token_type"
require_relative "./token"

class AstPrinter 
  include ExprVisitor
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
end
