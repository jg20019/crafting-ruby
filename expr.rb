class Expr
  def accept(visitor) end
end

class Visitor
    def  visitBinaryExpr (expr) end
    def  visitGroupingExpr (expr) end
    def  visitLiteralExpr (expr) end
    def  visitUnaryExpr (expr) end
end

class Binary < expr
    attr_accessor :left, :operator, :right
    def accept(visitor)
        visitor.visitBinaryExpr(self)
    end
end

class Grouping < expr
    attr_accessor :expression
    def accept(visitor)
        visitor.visitGroupingExpr(self)
    end
end

class Literal < expr
    attr_accessor :value
    def accept(visitor)
        visitor.visitLiteralExpr(self)
    end
end

class Unary < expr
    attr_accessor :operator, :right
    def accept(visitor)
        visitor.visitUnaryExpr(self)
    end
end

