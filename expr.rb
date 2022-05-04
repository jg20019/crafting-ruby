class Expr
  def accept(visitor) end
end

class Visitor
    def  visitBinaryExpr (expr)
        raise NotImplementedError
    end
    def  visitGroupingExpr (expr)
        raise NotImplementedError
    end
    def  visitLiteralExpr (expr)
        raise NotImplementedError
    end
    def  visitUnaryExpr (expr)
        raise NotImplementedError
    end
end

class Binary < Expr
    attr_accessor :left, :operator, :right
    def accept(visitor)
        visitor.visitBinaryExpr(self)
    end
end

class Grouping < Expr
    attr_accessor :expression
    def accept(visitor)
        visitor.visitGroupingExpr(self)
    end
end

class Literal < Expr
    attr_accessor :value
    def accept(visitor)
        visitor.visitLiteralExpr(self)
    end
end

class Unary < Expr
    attr_accessor :operator, :right
    def accept(visitor)
        visitor.visitUnaryExpr(self)
    end
end
