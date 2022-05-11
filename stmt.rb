module StmtVisitor
    def  visitExpressionStmt (stmt)
        raise NotImplementedError
    end
    def  visitPrintStmt (stmt)
        raise NotImplementedError
    end
end

class Expression
    attr_accessor :expression
    def initialize(expression)
        @expression = expression
    end

    def accept(visitor)
        visitor.visitExpressionStmt(self)
    end
end

class Print
    attr_accessor :expression
    def initialize(expression)
        @expression = expression
    end

    def accept(visitor)
        visitor.visitPrintStmt(self)
    end
end

