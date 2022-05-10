class Stmt
  def accept(visitor) end
end

class Visitor
    def  visitExpressionStmt (stmt)
        raise NotImplementedError
    end
    def  visitPrintStmt (stmt)
        raise NotImplementedError
    end
end

class Expression < Stmt
    attr_accessor :expression
    def accept(visitor)
        visitor.visitExpressionStmt(self)
    end
end

class Print < Stmt
    attr_accessor :expression
    def accept(visitor)
        visitor.visitPrintStmt(self)
    end
end

